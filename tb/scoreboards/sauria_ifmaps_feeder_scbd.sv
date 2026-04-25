class sauria_ifmaps_feeder_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_ifmaps_feeder_scbd)

    `uvm_analysis_imp_decl (_ifmaps_feeder_info)
    uvm_analysis_imp_ifmaps_feeder_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_info; 

    `uvm_analysis_imp_decl (_ifmaps_feeder_srama_access_info)
    uvm_analysis_imp_ifmaps_feeder_srama_access_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_srama_access_info;

    `uvm_analysis_imp_decl (_ifmaps_feeder_arr_info)
    uvm_analysis_imp_ifmaps_feeder_arr_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_arr_info;
    
    sauria_computation_params  computation_params;
    sauria_ifmaps_feeder_model ifmaps_model;

    string message_id = "SAURIA_IFMAPS_FEEDER_SCBD";

    function new(string name="sauria_ifmaps_feeder_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_ifmaps_feeder_info              = new("SAURIA_IFMAPS_FEEDER_ANALYSIS_IMP", this);
        receive_ifmaps_feeder_srama_access_info = new("SAURIA_IFMAPS_FEEDEER_SRAMA_ACCESS_INFO", this);
        receive_ifmaps_feeder_arr_info          = new("SAURIA_IFMAPS_FEEDER_ARR_INFO_ANALYSIS_IMP", this);
    
        ifmaps_model                            = sauria_ifmaps_feeder_model::type_id::create("sauria_ifmaps_feeder_model");

        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")

        ifmaps_model.set_computation_params(computation_params);
    
    endfunction

    function write_ifmaps_feeder_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_info);
        if (ifmaps_feeder_info.feeder_clear && ifmaps_feeder_info.clearfifo) begin
            ifmaps_model.reset_model();
        end
    endfunction

    function write_ifmaps_feeder_srama_access_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_srama_access_info);
        ifmaps_feeder_srama_access_result_t access_result;
        ifmaps_feeder_data_t                feeder_data_inst;

        feeder_data_inst.srama_addr = ifmaps_feeder_srama_access_info.srama_addr;
        feeder_data_inst.srama_data = ifmaps_feeder_srama_access_info.srama_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMA Access Addr: 0x%0h Data: 0x%0h",
        ifmaps_feeder_srama_access_info.srama_addr ,ifmaps_feeder_srama_access_info.srama_data))

        access_result = ifmaps_model.observe_srama_access(feeder_data_inst,
                                                          ifmaps_feeder_srama_access_info.til_done);

        if (access_result.addr_mismatch)
            `sauria_error(message_id, $sformatf("SRAMA_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",
            access_result.exp_srama_addr, feeder_data_inst.srama_addr))

        if (access_result.tile_done_counter_mismatch)
            `sauria_error(message_id, $sformatf("Tile Done Condition And Counters Mismatch C_IDX: 0x%0h X_IDX: 0x%0h Y_IDX: 0x%0h",
            access_result.c_idx, access_result.x_idx, access_result.y_idx))
    endfunction 

    function write_ifmaps_feeder_arr_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_arr_info);
        ifmaps_feeder_arr_feed_result_t arr_feed_result;

        arr_feed_result = ifmaps_model.observe_arr_feed(ifmaps_feeder_arr_info.a_arr,
                    ifmaps_feeder_arr_info.start_feeding,
                    ifmaps_feeder_arr_info.pop_en,
                    ifmaps_feeder_arr_info.fifo_empty);

        if (arr_feed_result.valid_entry &&
            (arr_feed_result.exp_srama_data != arr_feed_result.exp_a_arr_data))
            `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMA Read Data Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
            arr_feed_result.srama_addr, arr_feed_result.exp_srama_data, arr_feed_result.exp_a_arr_data))
            
    endfunction

endclass
