class sauria_perf_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_perf_scbd)

    string message_id = "SAURIA_PERF_SCBD";

    sauria_axi4_lite_rd_txn_seq_item cfg_perf_data;
    sauria_ifmaps_feeder_seq_item    ifmaps_feeder_perf_data;
    sauria_weights_feeder_seq_item   weights_feeder_perf_data;
    sauria_systolic_array_seq_item   systolic_array_perf_data;
    sauria_psums_mgr_seq_item        psums_mgr_perf_data;
    
    `uvm_analysis_imp_decl (_cfg_perf_info)
    uvm_analysis_imp_cfg_perf_info #(sauria_axi4_lite_rd_txn_seq_item, sauria_perf_scbd)            receive_cfg_perf_info;

    `uvm_analysis_imp_decl (_ifmaps_feeder_perf_info)
    uvm_analysis_imp_ifmaps_feeder_perf_info #(sauria_ifmaps_feeder_seq_item, sauria_perf_scbd)     receive_ifmaps_feeder_perf_info;

    `uvm_analysis_imp_decl (_weights_feeder_perf_info)
    uvm_analysis_imp_weights_feeder_perf_info #(sauria_weights_feeder_seq_item, sauria_perf_scbd)   receive_weights_feeder_perf_info;

    `uvm_analysis_imp_decl (_systolic_array_perf_info)
    uvm_analysis_imp_systolic_array_perf_info #(sauria_systolic_array_seq_item, sauria_perf_scbd)   receive_systolic_array_perf_info;
    
    `uvm_analysis_imp_decl (_psums_mgr_perf_info)
    uvm_analysis_imp_psums_mgr_perf_info #(sauria_psums_mgr_seq_item, sauria_perf_scbd)             receive_psums_mgr_perf_info;

    function new(string name="sauria_perf_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cfg_perf_data   = sauria_axi4_lite_rd_txn_seq_item::type_id::create("sauria_axi4_lite_rd_txn_seq_item"); 
        receive_cfg_perf_info             = new("PERF_CFG_INFO_ANALYSIS_IMP", this);
        receive_ifmaps_feeder_perf_info   = new("PERF_IFMAPS_FEEDER_INFO_ANALYSIS_IMP", this);
        receive_weights_feeder_perf_info  = new("PERF_WEIGHTS_FEEDER_INFO_ANALYSIS_IMP", this);
        receive_systolic_array_perf_info  = new("PERF_SYSTOLIC_ARRAY_INFO_ANALYSIS_IMP", this);
        receive_psums_mgr_perf_info       = new("PERF_PSUMS_MGR_INFO_ANALYSIS_IMP", this);

    endfunction

    function write_cfg_perf_info(sauria_axi4_lite_rd_txn_seq_item  cfg_rd_txn_item);
        cfg_perf_data = cfg_rd_txn_item;
               
        `sauria_info(message_id, $sformatf("Got Perf Data Addr: 0x%0h Val: 0x%0h",
                cfg_perf_data.rd_addr_item.araddr, cfg_perf_data.rd_data_item.rdata ))
    endfunction

    
    function write_ifmaps_feeder_perf_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_item);
            bit feeder_active;
            ifmaps_feeder_perf_data = ifmaps_feeder_item;

            feeder_active = ifmaps_feeder_perf_data.pipeline_en && ifmaps_feeder_perf_data.feeder_en &&
                            ifmaps_feeder_perf_data.act_valid   && ifmaps_feeder_perf_data.pop_en;

            //Fields Of Interest
            //ifmaps_feeder_perf_data.pipeline_en
            //ifmaps_feeder_perf_data.feeder_en   
            //ifmaps_feeder_perf_data.act_valid     
            //ifmaps_feeder_perf_data.pop_en 
            //ifmaps_feeder_perf_data.srama_rden   
	        //ifmaps_feeder_perf_data.fifo_empty  
            //ifmaps_feeder_perf_data.fifo_full 
            //ifmaps_feeder_perf_data.feeder_stall
            
    endfunction 
    
    function write_weights_feeder_perf_info(sauria_weights_feeder_seq_item weights_feeder_item);
            bit feeder_active;
            weights_feeder_perf_data = weights_feeder_item;

            feeder_active = weights_feeder_perf_data.pipeline_en && weights_feeder_perf_data.feeder_en &&
                            weights_feeder_perf_data.wei_valid && weights_feeder_perf_data.pop_en;

            //Fields Of Interest
            //weights_feeder_perf_data.pipeline_en
            //weights_feeder_perf_data.feeder_en   
            //weights_feeder_perf_data.wei_valid     
            //weights_feeder_perf_data.pop_en 
            //weights_feeder_perf_data.sramb_rden   
	        //weights_feeder_perf_data.fifo_empty  
            //weights_feeder_perf_data.fifo_full 
            //weights_feeder_perf_data.feeder_stall
            
    endfunction 

    function write_systolic_array_perf_info(sauria_systolic_array_seq_item systolic_array_item);
        systolic_array_perf_data = systolic_array_item;

        //Fields Of Interest 
        //systolic_array_perf_info.pipeline_en =  sauria_systolic_array_if.pipeline_en;
        //systolic_array_perf_info.cswitch_arr =  sauria_systolic_array_if.cswitch_arr;
        
    endfunction
    
    function write_psums_mgr_perf_info(sauria_psums_mgr_seq_item  psums_mgr_item);
        psums_mgr_perf_data = psums_mgr_item;
        
        //Fields Of Interest
        //psums_mgr_perf_data.sramc_rden;
        //psums_mgr_perf_data.sramc_wren;
        //psums_mgr_perf_data.cscan_en ;  

    endfunction

endclass