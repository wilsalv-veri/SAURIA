import sauria_common_pkg::*;
import uvm_pkg::*;

module sauria_ss_cov#(AXI_LITE_DATA_WIDTH,
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

    sauria_axi4_lite_addr_t io_cfg_port_aw_addr      = 32'hffff_ffff;
    sauria_axi4_lite_addr_t ctrl_udma_aw_addr        = 32'hffff_ffff;
    sauria_axi4_lite_addr_t ctrl_sauria_core_aw_addr = 32'hffff_ffff;
    
    sauria_axi4_lite_data_t io_cfg_port_w_data;
    sauria_axi4_lite_data_t ctrl_udma_w_data;
    sauria_axi4_lite_data_t ctrl_sauria_core_w_data;
    
    sauria_axi4_addr_t      io_mem_port_aw_addr;
    sauria_axi4_addr_t      io_mem_port_ar_addr;
    
    sauria_axi4_addr_t      dma_mem_sauria_aw_addr;
    sauria_axi4_addr_t      dma_mem_sauria_ar_addr;

    always @(posedge i_system_clk)begin

        //ADDRESS
        if (io_cfg_port.aw_valid) io_cfg_port_aw_addr <= io_cfg_port.aw_addr;
        //else io_cfg_port_aw_addr <= 32'hffff_ffff;

        if (ctrl_udma.aw_valid) ctrl_udma_aw_addr <= ctrl_udma.aw_addr;
        //else ctrl_udma_aw_addr <= 32'hffff_ffff;

        if (ctrl_sauria_core.aw_valid) ctrl_sauria_core_aw_addr <= ctrl_sauria_core.aw_addr;
        //else ctrl_sauria_core_aw_addr <=  32'hffff_ffff;

        if(io_mem_port.aw_valid) io_mem_port_aw_addr <= io_mem_port.aw_addr;
        //else io_mem_port_aw_addr  <= 32'hffff_ffff;

        if(io_mem_port.ar_valid) io_mem_port_ar_addr <= io_mem_port.ar_addr;
        //else io_mem_port_ar_addr  <= 32'hffff_ffff;

        if (dma_mem_sauria.aw_valid) dma_mem_sauria_aw_addr <= dma_mem_sauria.aw_addr;
        //else dma_mem_sauria_aw_addr <= 32'hffff_ffff;

        if (dma_mem_sauria.ar_valid) dma_mem_sauria_ar_addr <= dma_mem_sauria.ar_addr;
        //else dma_mem_sauria_ar_addr <= 32'hffff_ffff;

        //DATA
        if (io_cfg_port.w_valid) io_cfg_port_w_data <= io_cfg_port.w_data;
        else io_cfg_port_w_data <= 32'h0000_0000;

        if (ctrl_udma.w_valid) ctrl_udma_w_data <= ctrl_udma.w_data;
        else ctrl_udma_w_data <= 32'h0000_0000;

        if (ctrl_sauria_core.w_valid) ctrl_sauria_core_w_data <= ctrl_sauria_core.w_data;
        else ctrl_sauria_core_w_data <=  32'h0000_0000;
    end

    covergroup sauria_ss_cg @(posedge i_system_clk);
        option.per_instance = 1;
        
        //Interrupt cov
        coverpoint sauria_intr2control{
            bins core_computations_done        = {1};
        }
        
        coverpoint dma_rd_intr2control{
            bins dma_reader_done               = {1};
        }
        coverpoint dma_wr_intr2control{
            bins dma_writer_done               = {1};
        }
        
        coverpoint o_intr {
            bins df_controller_done            = {1};
        }


        //CFG
        //DF Controller
        coverpoint io_cfg_port_aw_addr{
            bins df_controller_start_addr      = {sauria_addr_pkg::CONTROLLER_OFFSET}; 
        }
        
        coverpoint io_cfg_port_w_data{
            wildcard bins df_controller_fsm_start_data  = {32'b???????????????????????????????1};
        }

        //DMA
        coverpoint ctrl_udma_aw_addr{
            bins dma_start_reader_writer_addr  = {0}; //sauria_addr_pkg::DMA_OFFSET
        }

        coverpoint ctrl_udma_w_data{                
            wildcard bins dma_reader_start_data  = {32'b???????????????????????????????1};
            wildcard bins dma_writer_start_data  = {32'b??????????????????????????????1?};
        }

        //CORE
        coverpoint ctrl_sauria_core_aw_addr {
            bins core_start_addr                = {0}; //sauria_addr_pkg::SAURIA_OFFSET
        }
 
        coverpoint ctrl_sauria_core_w_data {
            wildcard bins core_start_fsm       = {32'b???????????????????????????????1};
        }
        
        //MEM<-DMA->SRAMs

        //MEM<->DMA
        coverpoint io_mem_port_aw_addr {
            bins writebackPSUMS_ToMem       = {START_SRAMC_MEM_ADDR};
        }

        coverpoint io_mem_port.w_valid {
            bins writeToMemDATA            = {1};
        }

        coverpoint io_mem_port_ar_addr {
            bins readIFMAPS_FromMem         = {START_SRAMA_MEM_ADDR};
            bins readWEIGHTS_FromMem        = {START_SRAMB_MEM_ADDR};
            bins readPSUMS_FromMem          = {START_SRAMC_MEM_ADDR};
        }

        coverpoint io_mem_port.ar_valid {
            bins readFromMemADDR            = {1};
        }

        coverpoint io_mem_port.r_valid {
            bins readFromMemDATA            = {1};
        }

        //DMA<->SRAMS
        coverpoint dma_mem_sauria.aw_valid {
            bins write2SRAMsADDR             = {1};
        }

        coverpoint dma_mem_sauria_aw_addr {
            
            bins writeIFMAPS_ToSRAM         = {START_SRAMA_LOCAL_ADDR};
            bins writeWEIGHTS_ToSRAM        = {START_SRAMB_LOCAL_ADDR};
            bins writePSUMS_ToSRAM          = {START_SRAMC_LOCAL_ADDR};
        
        }

        coverpoint dma_mem_sauria.w_valid {
            bins writeToSRAMsDATA           = {1};
        }

        coverpoint dma_mem_sauria.ar_valid {
            bins readFromSRAMSADDR          = {1};
        }

        coverpoint dma_mem_sauria_ar_addr {
            bins readPSUMS_FromSRAM         = {START_SRAMC_LOCAL_ADDR};    
        }

        coverpoint dma_mem_sauria.r_valid {
            bins readFromSRAMSDATA          = {1};
        }
            
        //Cfg Bus Crosses
        DF_CONTROLLER_START            :cross io_cfg_port_aw_addr, io_cfg_port_w_data;
        DMA_ENGINE_READER_WRITER_START :cross ctrl_udma_aw_addr, ctrl_udma_w_data;
        SAURIA_CORE_START              :cross ctrl_sauria_core_aw_addr, ctrl_sauria_core_w_data;

        //Mem Bus Crosses
        TILES_READ                     :cross io_mem_port_ar_addr, io_mem_port.r_valid; 

        PSUMS_MEM_WRITEBACK            :cross io_mem_port_aw_addr, io_mem_port.w_valid;

        TILES_DMA_SRAM_WRITE           :cross dma_mem_sauria_aw_addr, dma_mem_sauria.w_valid; 

        PSUMS_DMA_SRAM_READ            :cross dma_mem_sauria_ar_addr, dma_mem_sauria.r_valid; 
        
    endgroup
   
    sauria_ss_cg ss_cg = new();
            
endmodule

