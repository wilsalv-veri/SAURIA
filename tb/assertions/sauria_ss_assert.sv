import sauria_common_pkg::*;
import sauria_base_cfg_seqs_pkg::*;
import uvm_pkg::*;

module sauria_ss_assert #(AXI_LITE_DATA_WIDTH,
                          AXI_LITE_ADDR_WIDTH,
    
                          DATA_AXI_ADDR_WIDTH, 
                          DATA_AXI_DATA_WIDTH,
                          DATA_AXI_ID_WIDTH
                         )
                        (   
                        input i_system_clk,
                        input i_system_rst,
                            
                        input i_sauria_clk,
                        input i_sauria_rst,
                            
                        input o_intr,
                        input sauria_intr2control,
                        input dma_rd_intr2control,
                        input dma_wr_intr2control,
       
                        AXI_LITE.Slave    io_cfg_port, 
                        AXI_LITE.Slave    ctrl_sauria_core,
                        AXI_LITE.Slave    ctrl_udma,
                        AXI_LITE.Slave    sauria_cfg_port_LF,                                                      
                        AXI_BUS.Master    io_mem_port, 
                        AXI_BUS.Master    dma_mem_sauria

                        );

    
    parameter tile_XY_cr_idx   = 0;
    parameter tile_CK_cr_idx   = 1;
    
    parameter tile_X_start_bit = 0;
    parameter tile_X_end_bit   = 15;
    parameter tile_Y_start_bit = 16;
    parameter tile_Y_end_bit   = 31;
    
    parameter tile_C_start_bit = 0;
    parameter tile_C_end_bit   = 15;
    parameter tile_K_start_bit = 16;
    parameter tile_K_end_bit   = 31;
    
    parameter df_start_addr   = CFG_BASE_OFFSET; 
    parameter core_start_addr = 0;//CORE_CFG_BASE_OFFSET;

    parameter tile_XY_addr  = CFG_BASE_OFFSET + get_cfg_addr_from_idx(tile_XY_cr_idx);
    parameter tile_CK_addr  = CFG_BASE_OFFSET + get_cfg_addr_from_idx(tile_CK_cr_idx);
    
    sauria_computation_params computation_params;

    logic [31:0] tile_X;
    logic [31:0] tile_Y;
    logic [31:0] tile_C;
    logic [31:0] tile_K;

    logic [31:0] ifmaps_X;
    logic [31:0] ifmaps_Y;
    logic [31:0] ifmaps_C;
    
    logic [31:0] weights_W;
    logic [31:0] weights_K;

    logic [31:0] psums_X;
    logic [31:0] psums_Y;
    logic [31:0] psums_K;

    bit ifmaps;
    bit weights;
    bit psums;

    bit xy_set;
    bit ck_set;
    bit exp_reads_set;
    bit df_controller_start; 
    bit sauria_core_start;

    int ifmaps_tile_rd_counter;
    int weights_tile_rd_counter;
    int psums_tile_rd_counter;
    int psums_tile_wr_counter;

    int ifmaps_dma_iterations; 
    int weights_dma_iterations;
    int psums_dma_iterations;

    int exp_total_num_tiles;
    int exp_total_reads;
    int exp_total_writes;
    int exp_total_dma_ops;
    int exp_ifmaps_tile_reads;
    int exp_weights_tile_reads;
    int exp_psums_reads;
    int exp_psums_writes;
    
    bit got_computation_params_access;

    always @ (posedge i_system_clk) begin
        if (!got_computation_params_access)begin
            if (uvm_config_db #(sauria_computation_params)::get(null, "","computation_params", computation_params))begin
                `sauria_sva_info("Got Computation Params Access");
                got_computation_params_access = 1'b1;
                wait(computation_params.shared);
                tile_X = computation_params.tile_X;
                tile_Y = computation_params.tile_Y;
                tile_C = computation_params.tile_C;
                tile_K = computation_params.tile_K;
                
                ifmaps_X = computation_params.ifmaps_X;
                ifmaps_Y = computation_params.ifmaps_Y;
                ifmaps_C = computation_params.ifmaps_C;
                
                weights_W = computation_params.weights_W;
                weights_K = computation_params.weights_K;
                
                psums_X = computation_params.psums_X;
                psums_Y = computation_params.psums_Y + 1;
                psums_K = computation_params.psums_K;
                
                exp_reads_set          = 1'b1;
                
                ifmaps_dma_iterations  = ifmaps_Y * ifmaps_C;
                weights_dma_iterations = weights_W;
                psums_dma_iterations   = psums_Y * psums_K;

                exp_total_num_tiles    = tile_X * tile_Y * tile_C * tile_K;
                exp_ifmaps_tile_reads  = exp_total_num_tiles;
                exp_weights_tile_reads = tile_C * tile_K;
                exp_psums_reads   = exp_total_num_tiles;
                exp_psums_writes  = psums_dma_iterations * exp_total_num_tiles; 

                exp_total_reads   = exp_ifmaps_tile_reads + exp_weights_tile_reads + exp_psums_reads;
                exp_total_writes  = exp_psums_writes;
                exp_total_dma_ops = exp_total_reads + exp_psums_writes;

            
            end

        end
    end
    always @ (posedge (io_cfg_port.aw_valid && io_cfg_port.w_valid)) begin
        if (io_cfg_port.aw_addr == df_start_addr)begin
            df_controller_start <= io_cfg_port.w_data[0];
        end
        else df_controller_start <= 1'b0;
    end

                        
    always @ (posedge i_system_clk) begin
        if(ctrl_sauria_core.aw_valid)begin
            if (ctrl_sauria_core.aw_addr == core_start_addr)begin
                @ (posedge i_system_clk);
                if (ctrl_sauria_core.w_valid)begin
                    sauria_core_start <= ctrl_sauria_core.w_data[0];
                end
            end
            else sauria_core_start <= 1'b0;
        end
        else sauria_core_start <= 1'b0;
    end
      
    property computation_started;
        @ (posedge i_system_clk) $rose(df_controller_start) |=> s_eventually $rose(sauria_core_start);
    endproperty

    property computation_started_count(logic [31:0] num_tiles);
        logic [31:0] num_tiles_count;

        ($rose(df_controller_start), num_tiles_count = 0) |=>  (1, num_tiles_count += $rose(sauria_core_start)) [*1:$] ##0 (num_tiles_count == num_tiles);
    endproperty

    property computation_started_exp_count_finished(logic [31:0] num_tiles);
        logic [31:0] num_tiles_count;

        ($rose(df_controller_start), num_tiles_count = 0) |=>  first_match ((1, num_tiles_count += $rose(sauria_intr2control)) [*1:$] ##0 (num_tiles_count == num_tiles)) |-> s_eventually $rose(o_intr);
    endproperty
    
    property computation_ordered_count(logic [31:0] total_tiles);
    
        logic [31:0] num_tiles_started_count = 0;
        logic [31:0] num_tiles_done_count    = 0;

        $rose(sauria_core_start) |-> 
                                    (
                                      (1, num_tiles_started_count += $rose(sauria_core_start), 
                                          num_tiles_done_count    += $rose(sauria_intr2control)) [*1:$] 
                                        intersect (num_tiles_started_count >= num_tiles_done_count) [*0:$]
                                    ) 
                                    ##0 (num_tiles_started_count == total_tiles && num_tiles_done_count == total_tiles);
    endproperty
    
    property core_start_done_order;
        $rose(sauria_core_start) |=> (!sauria_core_start throughout sauria_intr2control[->1]);
    endproperty

    property count_dma_reads(logic [31:0] total_dma_reads);
        logic [31:0] dma_reads_count;
        
        ($rose(df_controller_start), dma_reads_count = 0) |-> strong ( (1, dma_reads_count = $rose(dma_mem_sauria.aw_valid) + 1) [*1:$] ##1 $rose(o_intr) ##0 (dma_reads_count == total_dma_reads));
    endproperty
    
    property count_dma_writes(logic [31:0] total_dma_writes);
        logic [31:0] dma_writes_count;

        ($rose(df_controller_start), dma_writes_count = 0) |-> strong ( (1, dma_writes_count = $rose(dma_mem_sauria.ar_valid) + 1) [*1:$] ##1 $rose(o_intr) ##0 (dma_writes_count == dma_writes_count));
    endproperty
    
    
    DF_CTRL_START_STARTS_SAURIA_CORE: assert property (computation_started ) else `sauria_sva_error("Sauria Core Never Started After Dataflow Controller Started");
    DF_CTRL_START_N_FINISH: assert property (@ (posedge i_system_clk) $rose(df_controller_start) |-> s_eventually $rose(o_intr)) else `sauria_sva_error("Dataflow Done Never Asserted After Start Started After Asserted");

    DF_CTRL_STARTS_SAURIA_CORE_COUNT :assert property ( @ (posedge i_system_clk) disable iff (!exp_reads_set) computation_started_count(exp_total_num_tiles)) else `sauria_sva_error("Sauria Core Number Of Starts Never Reached Number of Total Tiles");
    
    DF_CTRL_STARTS_ALL_COMPUTES_FINISH: assert property ( @ (posedge i_system_clk) disable iff (!exp_reads_set) computation_started_exp_count_finished(exp_total_num_tiles)) else `sauria_sva_error("Dataflow Controller Failed to Set Done Interrupt after Core Calculations Done");
    
    SAURIA_CORE_START_DONE_COUNT_PAIRS: assert property ( @ (posedge i_system_clk) disable iff (!exp_reads_set) computation_ordered_count(exp_total_num_tiles)) else `sauria_sva_error("Mismatch : Sauria Core Start Count != Sauria Core Done Count");
    
    CORE_NEVER_DONE_BEFORE_START: assert property ( @ (posedge i_system_clk) core_start_done_order) else `sauria_sva_error("Sauria Core Done Asserted Before Core Start");
    
    //FIXME: wilsalv :Enable Later
    //ALL_TILES_READ        : assert property ( @ (posedge i_system_clk ) disable iff (!exp_reads_set) count_dma_reads(exp_total_reads) ) else `sauria_sva_error("Missing Unread Tiles Or Tile Elements");
    //ALL_PSUMS_WRITTEN_BACK: assert property ( @ (posedge i_system_clk ) disable iff (!exp_reads_set) count_dma_writes(exp_total_writes) ) else `sauria_sva_error("Missing Writeback Tiles Or Tile Elements");
    
    //TODO: wilsalv
    //1) Count DMA Mem Writes and Confirm Total Writes = All PSUMS Written
    //2) Count DMA Reads and Confirm Total Reads = All Tensors Fully Read (IFMAPS + WEIGHS + PSUMS)
    //3) Check No Change In Config Between DF Controller Start and Interrupt Out Set

    assert property ( @ (posedge i_system_clk) $rose(df_controller_start) |-> s_eventually $rose(dma_rd_intr2control)) else `sauria_sva_error("DMA RD Interrupt Never Asserted");
    assert property ( @ (posedge i_system_clk) $rose(df_controller_start) |-> s_eventually $rose(dma_wr_intr2control)) else `sauria_sva_error("DMA WR Interrupt Never Asserted");
    assert property ( @ (posedge i_system_clk) $rose(df_controller_start) |-> s_eventually ($rose(dma_rd_intr2control) ##[0:5] $rose(dma_wr_intr2control))) else `sauria_sva_error("DMA WR Never Happened");
    
    assert property ( @ (posedge i_system_clk) $rose(df_controller_start) |->  strong ($rose(dma_mem_sauria.ar_valid)[->2688] ##[0:$] $rose(o_intr))) `sauria_sva_info("SUCCESS!!!"); else `sauria_sva_error("FAILURE :(");
    
endmodule