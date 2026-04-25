class sauria_env extends uvm_env;

    `uvm_component_utils(sauria_env)

    sauria_axi4_lite_agent        axi4_lite_agent;
    sauria_axi4_agent             axi4_agent;
    sauria_axi4_lite_adapter      axi4_lite_adapter;

    sauria_ss_reg_block           subsystem_reg_block;
   
    sauria_axi_vseqr              vseqr;
    
    sauria_dataflow_scbd          dataflow_scbd;

    sauria_main_controller_agent  main_controller_agent;
    sauria_main_controller_scbd   main_controller_scbd;

    sauria_ifmaps_feeder_agent    ifmaps_feeder_agent;
    sauria_ifmaps_feeder_scbd     ifmaps_feeder_scbd;

    sauria_weights_feeder_agent   weights_feeder_agent;
    sauria_weights_feeder_scbd    weights_feeder_scbd;

    sauria_systolic_array_agent   systolic_array_agent;
    sauria_systolic_array_scbd    systolic_array_scbd;

    sauria_psums_mgr_agent        psums_mgr_agent;
    sauria_psums_mgr_scbd         psums_mgr_scbd;

    sauria_perf_collector         perf_collector;

    function new(string name="sauria_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        vseqr               = sauria_axi_vseqr::type_id::create("sauria_axi_vseqr", this);
        axi4_lite_agent     = sauria_axi4_lite_agent::type_id::create("sauria_axi4_lite_agent", this);
        axi4_lite_adapter   = sauria_axi4_lite_adapter::type_id::create("sauria_axi4_lite_adapter", , get_full_name());
        
        subsystem_reg_block = sauria_ss_reg_block::type_id::create("sauria_ss_reg_block");
        subsystem_reg_block.configure();

        axi4_agent          = sauria_axi4_agent::type_id::create("sauria_axi4_agent", this);
        dataflow_scbd       = sauria_dataflow_scbd::type_id::create("sauria_dataflow_scbd", this);
        
        main_controller_agent = sauria_main_controller_agent::type_id::create("sauria_main_controller_agent", this);
        main_controller_scbd  = sauria_main_controller_scbd::type_id::create("sauria_main_controller_scbd", this);

        ifmaps_feeder_agent   = sauria_ifmaps_feeder_agent::type_id::create("sauria_ifmaps_feeder_agent", this);
        ifmaps_feeder_scbd    = sauria_ifmaps_feeder_scbd::type_id::create("sauria_ifmaps_feeder_scbd", this);

        weights_feeder_agent = sauria_weights_feeder_agent::type_id::create("sauria_weights_feeder_agent", this);
        weights_feeder_scbd  = sauria_weights_feeder_scbd::type_id::create("sauria_weights_feeder_scbd", this);

        systolic_array_agent = sauria_systolic_array_agent::type_id::create("sauria_systolic_array", this);
        systolic_array_scbd  = sauria_systolic_array_scbd::type_id::create("sauria_systolic_array_scbd", this);

        psums_mgr_agent     = sauria_psums_mgr_agent::type_id::create("sauria_psums_mgr_agent", this);
        psums_mgr_scbd      = sauria_psums_mgr_scbd::type_id::create("sauria_psums_mgr_scbd", this);
    
        perf_collector      = sauria_perf_collector::type_id::create("sauria_perf_collector", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
  
        subsystem_reg_block.dma_controller_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.df_controller_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.core_main_controller_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.core_weights_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.core_ifmaps_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.core_psums_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.df_controller_ctrl_status_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        subsystem_reg_block.core_ctrl_status_reg_block.default_map.set_sequencer(axi4_lite_agent.axi4_lite_seqr, axi4_lite_adapter);
        axi4_lite_agent.axi4_lite_seqr.subsystem_reg_block = subsystem_reg_block;

        axi4_agent.axi4_mon.send_dma_rd_addr.connect(dataflow_scbd.receive_dma_rd_addr);
        axi4_agent.axi4_mon.send_dma_wr_addr.connect(dataflow_scbd.receive_dma_wr_addr);
        axi4_agent.axi4_mon.send_dma_perf_info.connect(perf_collector.perf_logger.receive_dma_perf_info);
        
        main_controller_agent.main_controller_mon.send_main_controller_info.connect(main_controller_scbd.receive_main_controller_info);
        main_controller_agent.main_controller_mon.send_main_controller_info.connect(perf_collector.perf_logger.receive_main_controller_perf_info);
        
        ifmaps_feeder_agent.ifmaps_feeder_mon.send_ifmaps_feeder_info.connect(ifmaps_feeder_scbd.receive_ifmaps_feeder_info);
        ifmaps_feeder_agent.ifmaps_feeder_mon.send_ifmaps_feeder_srama_access_info.connect(ifmaps_feeder_scbd.receive_ifmaps_feeder_srama_access_info);
        ifmaps_feeder_agent.ifmaps_feeder_mon.send_ifmaps_feeder_arr_info.connect(ifmaps_feeder_scbd.receive_ifmaps_feeder_arr_info);
        ifmaps_feeder_agent.ifmaps_feeder_mon.send_ifmaps_feeder_perf_info.connect(perf_collector.perf_logger.receive_ifmaps_feeder_perf_info);
        
        weights_feeder_agent.weights_feeder_mon.send_weights_feeder_info.connect(weights_feeder_scbd.receive_weights_feeder_info);
        weights_feeder_agent.weights_feeder_mon.send_weights_feeder_sramb_access_info.connect(weights_feeder_scbd.receive_weights_feeder_sramb_access_info);
        weights_feeder_agent.weights_feeder_mon.send_weights_feeder_arr_info.connect(weights_feeder_scbd.receive_weights_feeder_arr_info);
        weights_feeder_agent.weights_feeder_mon.send_weights_feeder_perf_info.connect(perf_collector.perf_logger.receive_weights_feeder_perf_info);
        
        systolic_array_agent.systolic_array_mon.send_systolic_array_info.connect(systolic_array_scbd.receive_systolic_array_info);
        systolic_array_agent.systolic_array_mon.send_systolic_array_perf_info.connect(perf_collector.perf_logger.receive_systolic_array_perf_info);

        psums_mgr_agent.psums_mgr_mon.send_psums_mgr_sramc_read_info.connect(psums_mgr_scbd.receive_psums_mgr_sramc_read_info);
        psums_mgr_agent.psums_mgr_mon.send_psums_mgr_sramc_write_info.connect(psums_mgr_scbd.receive_psums_mgr_sramc_write_info);
        psums_mgr_agent.psums_mgr_mon.send_psums_mgr_preload_vals_info.connect(psums_mgr_scbd.receive_psums_mgr_preload_values_info);
        psums_mgr_agent.psums_mgr_mon.send_psums_mgr_shift_reg_info.connect(psums_mgr_scbd.receive_psums_mgr_shift_reg_info);
        psums_mgr_agent.psums_mgr_mon.send_psums_mgr_perf_info.connect(perf_collector.perf_logger.receive_psums_mgr_perf_info);

        perf_collector.axi4_lite_seqr = axi4_lite_agent.axi4_lite_seqr;
        axi4_lite_agent.axi4_lite_mon.send_cfg_perf_info.connect(perf_collector.perf_logger.receive_cfg_perf_info);
    endfunction

endclass