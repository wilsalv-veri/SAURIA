class sauria_weights_feeder_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_weights_feeder_scbd)

    `uvm_analysis_imp_decl(_weights_feeder_info)
    uvm_analysis_imp_weights_feeder_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_info;

    `uvm_analysis_imp_decl (_weights_feeder_sramb_access_info)
    uvm_analysis_imp_weights_feeder_sramb_access_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_sramb_access_info;

    `uvm_analysis_imp_decl (_weights_feeder_arr_info)
    uvm_analysis_imp_weights_feeder_arr_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_arr_info;
    
    string message_id = "SAURIA_WEIGHTS_FEEDER_SCBD";
    
    sauria_computation_params  computation_params;
    sauria_weights_feeder_model weights_model;
    
    function new(string name="sauria_weights_feeder_scbd", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_weights_feeder_info              = new("SAURIA_WEIGHTS_FEEDER_ANALYSIS_IMP", this);
        receive_weights_feeder_sramb_access_info = new("SAURIA_WEIGHTS_FEEDEER_SRAMB_ACCESS_INFO", this);
        receive_weights_feeder_arr_info          = new("SAURIA_WEIGHTS_FEEDER_ARR_INFO_ANALYSIS_IMP", this);
    
        weights_model                            = sauria_weights_feeder_model::type_id::create("sauria_weights_feeder_model");

        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")

        weights_model.set_computation_params(computation_params);
    
    endfunction
    
    function write_weights_feeder_info(sauria_weights_feeder_seq_item weights_feeder_info);
        if (weights_feeder_info.feeder_clear && weights_feeder_info.clearfifo) begin
            weights_model.reset_model();
        end
    endfunction

    function write_weights_feeder_sramb_access_info(sauria_weights_feeder_seq_item weights_feeder_sramb_access_info);
        weights_feeder_sramb_access_result_t access_result;
        weights_feeder_data_t                feeder_data_inst;

        feeder_data_inst.sramb_addr = weights_feeder_sramb_access_info.sramb_addr;
        feeder_data_inst.sramb_data = weights_feeder_sramb_access_info.sramb_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMB Access Addr: 0x%0h Data: 0x%0h",
        feeder_data_inst.sramb_addr ,feeder_data_inst.sramb_data))

        access_result = weights_model.observe_sramb_access(feeder_data_inst,
                                                           weights_feeder_sramb_access_info.til_done);

        if (access_result.tile_done_counter_mismatch)
            `sauria_error(message_id, $sformatf("Tile Done Condition And Counters Mismatch W_IDX: 0x%0h K_IDX: 0x%0h",
            access_result.w_idx, access_result.k_idx))

        if (access_result.addr_mismatch)
            `sauria_error(message_id, $sformatf("SRAMB_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",
            access_result.exp_sramb_addr, feeder_data_inst.sramb_addr))
        
    endfunction 

    function write_weights_feeder_arr_info(sauria_weights_feeder_seq_item weights_feeder_arr_info);
        weights_feeder_arr_feed_result_t arr_feed_result;
        
        arr_feed_result = weights_model.observe_arr_feed(weights_feeder_arr_info.b_arr,
                                                         weights_feeder_arr_info.start_feeding,
                                                         weights_feeder_arr_info.pop_en,
                                                         weights_feeder_arr_info.fifo_empty);

        if (arr_feed_result.valid_entry &&
            (arr_feed_result.exp_sramb_data != arr_feed_result.exp_b_arr_data))
            `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMB Read Data Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    arr_feed_result.sramb_addr ,arr_feed_result.exp_sramb_data, arr_feed_result.exp_b_arr_data ))
    endfunction
    
endclass

