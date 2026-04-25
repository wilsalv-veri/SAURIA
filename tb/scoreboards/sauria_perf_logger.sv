class sauria_perf_logger extends uvm_scoreboard;

    `uvm_component_utils(sauria_perf_logger)

    string message_id = "SAURIA_PERF_LOGGER";
    string default_perf_log_path = "SA_perf_log.csv";
    string perf_log_path = "sauria_perf_log.csv";

    int perf_log_fd;
    virtual sauria_subsystem_ifc sauria_ss_if;
    virtual sauria_core_ifc sauria_core_if;
    virtual sauria_axi4_ifc axi4_mem_if;

    sauria_axi4_lite_rd_txn_seq_item core_perf_data;
    sauria_axi4_lite_wr_txn_seq_item ss_perf_data;
    
    sauria_ifmaps_feeder_seq_item    ifmaps_feeder_perf_data;
    sauria_weights_feeder_seq_item   weights_feeder_perf_data;
    sauria_main_controller_seq_item  main_controller_perf_data;
    sauria_systolic_array_seq_item   systolic_array_perf_data;
    sauria_psums_mgr_seq_item        psums_mgr_perf_data;
    
    `uvm_analysis_imp_decl (_cfg_perf_info)
    uvm_analysis_imp_cfg_perf_info #(sauria_axi_txn_base_seq_item, sauria_perf_logger)            receive_cfg_perf_info;

    `uvm_analysis_imp_decl (_dma_perf_info)
    uvm_analysis_imp_dma_perf_info #(sauria_axi_txn_base_seq_item, sauria_perf_logger)                receive_dma_perf_info;

    `uvm_analysis_imp_decl (_ifmaps_feeder_perf_info)
    uvm_analysis_imp_ifmaps_feeder_perf_info #(sauria_ifmaps_feeder_seq_item, sauria_perf_logger)     receive_ifmaps_feeder_perf_info;

    `uvm_analysis_imp_decl (_weights_feeder_perf_info)
    uvm_analysis_imp_weights_feeder_perf_info #(sauria_weights_feeder_seq_item, sauria_perf_logger)   receive_weights_feeder_perf_info;

    `uvm_analysis_imp_decl (_main_controller_perf_info)
    uvm_analysis_imp_main_controller_perf_info #(sauria_main_controller_seq_item, sauria_perf_logger) receive_main_controller_perf_info;

    `uvm_analysis_imp_decl (_systolic_array_perf_info)
    uvm_analysis_imp_systolic_array_perf_info #(sauria_systolic_array_seq_item, sauria_perf_logger)   receive_systolic_array_perf_info;
    
    `uvm_analysis_imp_decl (_psums_mgr_perf_info)
    uvm_analysis_imp_psums_mgr_perf_info #(sauria_psums_mgr_seq_item, sauria_perf_logger)             receive_psums_mgr_perf_info;

    function new(string name="sauria_perf_scbd", uvm_component parent=null);
        super.new(name, parent);
        perf_log_path = default_perf_log_path;
    endfunction

    function automatic string format_bit_csv(bit value);
        return value ? "1" : "0";
    endfunction

    function automatic string format_int_csv(int value);
        string formatted_value;

        formatted_value.itoa(value);
        return formatted_value;
    endfunction

    function void open_perf_log();
        string perf_log_override;

        perf_log_path = default_perf_log_path;

        if (sauria_plusarg_utils::get_plusarg_value_if_exists("SAURIA_PERF_LOG_FILE", perf_log_override)) begin
            if (perf_log_override.len() > 0) begin
                perf_log_path = perf_log_override;
                `sauria_info(message_id, $sformatf("Using perf log path from plusarg: %0s", perf_log_path))
            end
            else begin
                `sauria_info(message_id, $sformatf("Ignoring empty SAURIA_PERF_LOG_FILE override. Using default path: %0s", perf_log_path))
            end
        end

        perf_log_fd = $fopen(perf_log_path, "w");

        if ((perf_log_fd == 0) && (perf_log_path != default_perf_log_path)) begin
            `sauria_info(message_id, $sformatf("Failed to open requested perf log path: %0s. Retrying with default path: %0s", perf_log_path, default_perf_log_path))
            perf_log_path = default_perf_log_path;
            perf_log_fd = $fopen(perf_log_path, "w");
        end

        if (perf_log_fd == 0)
            `sauria_fatal(message_id, $sformatf("Failed to open perf log file: %0s", perf_log_path))

          $fdisplay(perf_log_fd,
              "time,source,txn_type,addr,data,pipeline_en,feeder_en,act_valid,wei_valid,pop_en,srama_rden,sramb_rden,fifo_empty,fifo_full,feeder_stall,feeder_active,cscan_en,sramc_rden,sramc_wren,context_num,cswitch,ctx_status,feed_status,feed_deadlock,df_done,core_start,core_done,dma_arvalid,dma_rvalid,dma_awvalid,dma_wvalid");
    endfunction

    function void close_perf_log();
        if (perf_log_fd != 0) begin
            $fclose(perf_log_fd);
            perf_log_fd = 0;
        end
    endfunction

    function void log_perf_row(
        string source,
        string txn_type,
        string addr,
        string data,
        string pipeline_en,
        string feeder_en,
        string act_valid,
        string wei_valid,
        string pop_en,
        string srama_rden,
        string sramb_rden,
        string fifo_empty,
        string fifo_full,
        string feeder_stall,
        string feeder_active,
        string cscan_en,
        string sramc_rden,
        string sramc_wren,
        string context_num,
        string cswitch,
        string ctx_status = "",
        string feed_status = "",
        string feed_deadlock = "",
        string df_done = "",
        string core_start = "",
        string core_done = "",
        string dma_arvalid = "",
        string dma_rvalid = "",
        string dma_awvalid = "",
        string dma_wvalid = ""
    );
        if (perf_log_fd == 0)
            return;

          $fdisplay(perf_log_fd,
              "%0t,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s,%0s",
                  $time,
                  source,
                  txn_type,
                  addr,
                  data,
                  pipeline_en,
                  feeder_en,
                  act_valid,
                  wei_valid,
                  pop_en,
                  srama_rden,
                  sramb_rden,
                  fifo_empty,
                  fifo_full,
                  feeder_stall,
                  feeder_active,
                  cscan_en,
                  sramc_rden,
                  sramc_wren,
                  context_num,
                  cswitch,
                  ctx_status,
                  feed_status,
                  feed_deadlock,
                  df_done,
                  core_start,
                  core_done,
                  dma_arvalid,
                  dma_rvalid,
                  dma_awvalid,
                  dma_wvalid);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        core_perf_data   = sauria_axi4_lite_rd_txn_seq_item::type_id::create("sauria_axi4_lite_rd_txn_seq_item"); 
        ss_perf_data     = sauria_axi4_lite_wr_txn_seq_item::type_id::create("sauria_axi4_lite_wr_txn_seq_item"); 

        open_perf_log();
        
        receive_cfg_perf_info             = new("PERF_CFG_INFO_ANALYSIS_IMP", this);
        receive_dma_perf_info             = new("PERF_DMA_INFO_ANALYSIS_IMP", this);
        receive_ifmaps_feeder_perf_info   = new("PERF_IFMAPS_FEEDER_INFO_ANALYSIS_IMP", this);
        receive_weights_feeder_perf_info  = new("PERF_WEIGHTS_FEEDER_INFO_ANALYSIS_IMP", this);
        receive_main_controller_perf_info = new("PERF_MAIN_CONTROLLER_INFO_ANALYSIS_IMP", this);
        receive_systolic_array_perf_info  = new("PERF_SYSTOLIC_ARRAY_INFO_ANALYSIS_IMP", this);
        receive_psums_mgr_perf_info       = new("PERF_PSUMS_MGR_INFO_ANALYSIS_IMP", this);

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

        if (!uvm_config_db #(virtual sauria_core_ifc)::get(this, "", "sauria_core_if", sauria_core_if))
            `sauria_error(message_id, "Failed to get access to sauria_core_if")

        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(this, "", "sauria_axi4_mem_if", axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to axi4_mem_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork
            monitor_done_interrupts();
        join_none
    endtask

    virtual function void final_phase(uvm_phase phase);
        super.final_phase(phase);
        close_perf_log();
    endfunction

    task monitor_done_interrupts();
        forever @(posedge sauria_ss_if.i_system_clk) begin
            if (axi4_mem_if.axi4_rd_addr_ch.arvalid ||
                axi4_mem_if.axi4_rd_data_ch.rvalid ||
                axi4_mem_if.axi4_wr_addr_ch.awvalid ||
                axi4_mem_if.axi4_wr_data_ch.wvalid) begin
                log_perf_row(
                    "dma_status", "", "", "",
                    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                    "", "", "",
                    "",
                    "",
                    "",
                    format_bit_csv(axi4_mem_if.axi4_rd_addr_ch.arvalid),
                    format_bit_csv(axi4_mem_if.axi4_rd_data_ch.rvalid),
                    format_bit_csv(axi4_mem_if.axi4_wr_addr_ch.awvalid),
                    format_bit_csv(axi4_mem_if.axi4_wr_data_ch.wvalid)
                );
            end
            if (sauria_ss_if.o_sauriaintr) begin
                log_perf_row(
                    "subsystem", "", "", "",
                    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                    "", "", "",
                    "1",
                    "",
                    ""
                );
            end
            if (sauria_core_if.mc_start) begin
                log_perf_row(
                    "subsystem", "", "", "",
                    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                    "", "", "",
                    "",
                    "1",
                    ""
                );
            end
            if (sauria_core_if.o_doneintr) begin
                log_perf_row(
                    "subsystem", "", "", "",
                    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
                    "", "", "",
                    "",
                    "",
                    "1"
                );
            end
        end
    endtask

    function write_cfg_perf_info(sauria_axi_txn_base_seq_item  cfg_txn_item);
        
        if ($cast(core_perf_data, cfg_txn_item))begin
            log_perf_row("cfg", "rd",
                         $sformatf("0x%0h", core_perf_data.rd_addr_item.araddr),
                         $sformatf("0x%0h", core_perf_data.rd_data_item.rdata),
                         "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
               
            `sauria_info(message_id, $sformatf("Got Perf Data Addr: 0x%0h Val: 0x%0h",
                    core_perf_data.rd_addr_item.araddr, core_perf_data.rd_data_item.rdata ))
        end
        else if ($cast(ss_perf_data, cfg_txn_item))begin
            log_perf_row("cfg", "wr",
                         $sformatf("0x%0h", ss_perf_data.wr_addr_item.awaddr),
                         $sformatf("0x%0h", ss_perf_data.wr_data_item.wdata),
                         "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
               
            `sauria_info(message_id, $sformatf("Got Perf Data Addr: 0x%0h Val: 0x%0h",
                    ss_perf_data.wr_addr_item.awaddr, ss_perf_data.wr_data_item.wdata ))
        end 

    endfunction

    function write_dma_perf_info(sauria_axi_txn_base_seq_item dma_txn);
        sauria_axi4_rd_txn_seq_item dma_rd_txn;
        sauria_axi4_wr_txn_seq_item dma_wr_txn;

        if ($cast(dma_rd_txn, dma_txn)) begin
            log_perf_row("dma", "rd",
                         $sformatf("0x%0h", dma_rd_txn.rd_addr_item.araddr),
                         $sformatf("0x%0h", dma_rd_txn.rd_data_item.rdata),
                         "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        end
        else if ($cast(dma_wr_txn, dma_txn)) begin
            log_perf_row("dma", "wr",
                         $sformatf("0x%0h", dma_wr_txn.wr_addr_item.awaddr),
                         $sformatf("0x%0h", dma_wr_txn.wr_data_item.wdata),
                         "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "");
        end

    endfunction

    function write_main_controller_perf_info(sauria_main_controller_seq_item main_controller_item);
        main_controller_perf_data = main_controller_item;

        log_perf_row("main_controller", "", "", "",
                     format_bit_csv(main_controller_perf_data.pipeline_en),
                     "",
                     format_bit_csv(main_controller_perf_data.act_valid),
                     format_bit_csv(main_controller_perf_data.wei_valid),
                     "", "", "", "", "", "", "", "", "", "", "",
                     format_bit_csv(main_controller_perf_data.cswitch_arr != arr_row_data_t'(0)),
                     $sformatf("%0d", main_controller_perf_data.ctx_status),
                     $sformatf("%0d", main_controller_perf_data.feed_status),
                     format_bit_csv(main_controller_perf_data.feed_deadlock));
    endfunction

    function write_ifmaps_feeder_perf_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_item);
        bit feeder_active;
        ifmaps_feeder_perf_data = ifmaps_feeder_item;

        feeder_active = ifmaps_feeder_perf_data.pipeline_en && ifmaps_feeder_perf_data.feeder_en &&
                        ifmaps_feeder_perf_data.act_valid   && ifmaps_feeder_perf_data.pop_en;

            
        log_perf_row("ifmaps_feeder", "",
             $sformatf("0x%0h", ifmaps_feeder_perf_data.srama_addr), "",
             format_bit_csv(ifmaps_feeder_perf_data.pipeline_en),
             format_bit_csv(ifmaps_feeder_perf_data.feeder_en),
             format_bit_csv(ifmaps_feeder_perf_data.act_valid),
             "",
             format_bit_csv(ifmaps_feeder_perf_data.pop_en),
             format_bit_csv(ifmaps_feeder_perf_data.srama_rden),
             "",
             format_bit_csv(ifmaps_feeder_perf_data.fifo_empty),
             format_bit_csv(ifmaps_feeder_perf_data.fifo_full),
             format_bit_csv(ifmaps_feeder_perf_data.feeder_stall),
             format_bit_csv(feeder_active),
             "", "", "", "", "", "", "", "");
            
    endfunction 
    
    function write_weights_feeder_perf_info(sauria_weights_feeder_seq_item weights_feeder_item);
        bit feeder_active;
        weights_feeder_perf_data = weights_feeder_item;

        feeder_active = weights_feeder_perf_data.pipeline_en && weights_feeder_perf_data.feeder_en &&
                        weights_feeder_perf_data.wei_valid && weights_feeder_perf_data.pop_en;

        
        log_perf_row("weights_feeder", "",
                     $sformatf("0x%0h", weights_feeder_perf_data.sramb_addr), "",
                     format_bit_csv(weights_feeder_perf_data.pipeline_en),
                     format_bit_csv(weights_feeder_perf_data.feeder_en),
                     "",
                     format_bit_csv(weights_feeder_perf_data.wei_valid),
                     format_bit_csv(weights_feeder_perf_data.pop_en),
                     "",
                     format_bit_csv(weights_feeder_perf_data.sramb_rden),
                     format_bit_csv(weights_feeder_perf_data.fifo_empty),
                     format_bit_csv(weights_feeder_perf_data.fifo_full),
                     format_bit_csv(weights_feeder_perf_data.feeder_stall),
                     format_bit_csv(feeder_active),
                     "", "", "", "", "", "", "", "");
            
    endfunction 

    function write_systolic_array_perf_info(sauria_systolic_array_seq_item systolic_array_item);
        systolic_array_perf_data = systolic_array_item;

        log_perf_row("systolic_array", "", "", "",
                     format_bit_csv(systolic_array_perf_data.pipeline_en),
                     "",
                     format_bit_csv(systolic_array_perf_data.act_data_valid),
                     format_bit_csv(systolic_array_perf_data.wei_data_valid),
                     "", "", "", "", "", "", "",
                     format_bit_csv(systolic_array_perf_data.cscan_en),
                     "", "", "",
                     format_bit_csv(systolic_array_perf_data.cswitch_arr != arr_row_data_t'(0)),
                     "", "", "");
        
    endfunction
    
    function write_psums_mgr_perf_info(sauria_psums_mgr_seq_item  psums_mgr_item);
        psums_mgr_perf_data = psums_mgr_item;
        
        log_perf_row("psums_mgr", "",
                     $sformatf("0x%0h", psums_mgr_perf_data.sramc_addr),
                     $sformatf("0x%0h", psums_mgr_perf_data.sramc_wdata),
                     "", "", "", "", "", "", "", "", "", "", "",
                     format_bit_csv(psums_mgr_perf_data.cscan_en),
                     format_bit_csv(psums_mgr_perf_data.sramc_rden),
                     format_bit_csv(psums_mgr_perf_data.sramc_wren),
                     format_int_csv(psums_mgr_perf_data.context_num),
                     "",
                     "", "", "");

    endfunction

endclass