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
    
    weights_feeder_data_t      feeder_data_inst;
    srama_addr_t               fed_entry_sramb_addr;
    b_arr_data_t               b_arr;
    sramb_data_t               sramb_data;
    
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
    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.main_controller_cfg_shared);
        
        weights_model.set_incntlim(computation_params.incntlim);
        weights_model.set_reps(computation_params.act_reps, 
                               computation_params.wei_reps);
    
        wait(computation_params.weights_cfg_shared);
        weights_model.configure(computation_params.core_weights_params, 
                                computation_params.weights_cols_active);
    endtask
    
    function write_weights_feeder_info(sauria_weights_feeder_seq_item weights_feeder_info);
        if (weights_feeder_info.feeder_clear && weights_feeder_info.clearfifo) begin
            weights_model.reset_model();
        end
    endfunction

    function write_weights_feeder_sramb_access_info(sauria_weights_feeder_seq_item weights_feeder_sramb_access_info);
        feeder_data_inst.sramb_addr = weights_feeder_sramb_access_info.sramb_addr;
        feeder_data_inst.sramb_data = weights_feeder_sramb_access_info.sramb_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMB Access Addr: 0x%0h Data: 0x%0h",
        feeder_data_inst.sramb_addr ,feeder_data_inst.sramb_data))

        check_sramb_rd_addr(feeder_data_inst.sramb_addr);
        weights_model.add_weights_sram_access(feeder_data_inst);
        
        if (weights_feeder_sramb_access_info.til_done) check_tile_done_counters();
    
    endfunction 

    function write_weights_feeder_arr_info(sauria_weights_feeder_seq_item weights_feeder_arr_info);
        
        if (weights_feeder_arr_info.start_feeding)
            weights_model.set_overlapping_comp();
        
        weights_model.add_weights_systolic_feed_data(weights_feeder_arr_info.b_arr);
        
        if(weights_model.has_valid_entry() && !weights_feeder_arr_info.fifo_empty)
            check_weights_fed_data();
        
        if(!(weights_feeder_arr_info.pop_en || weights_model.is_overlapping_comps()))
            weights_model.clear_arr_byte_valids();
        
        weights_model.update_comp_indeces();
    endfunction

    virtual function void check_sramb_rd_addr(sramb_addr_t sramb_rd_addr);
        if (weights_model.get_next_exp_sramb_rd_addr() != sramb_rd_addr)
            `sauria_error(message_id, $sformatf("SRAMB_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",  
        weights_model.get_next_exp_sramb_rd_addr(), sramb_rd_addr))
    endfunction

    virtual function void check_weights_fed_data();
        fed_entry_sramb_addr = weights_model.get_valid_entry_sramb_addr();
        sramb_data           = weights_model.get_valid_sramb_data();
        b_arr                = weights_model.get_valid_b_arr_data();
        
        if (sramb_data != b_arr)  
            `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMB Read Data Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    fed_entry_sramb_addr ,sramb_data, b_arr ))
                
    endfunction

    virtual function void check_tile_done_counters();
        if (!(weights_model.get_w_idx() == sramb_addr_t'(0) && 
              weights_model.get_k_idx() == sramb_addr_t'(0)))
            `sauria_error(message_id, $sformatf("Tile Done Condition And Counters Mismatch W_IDX: 0x%0h K_IDX: 0x%0h", 
              weights_model.get_w_idx(), weights_model.get_k_idx()))
    endfunction
    
endclass

