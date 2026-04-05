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
    
    ifmaps_feeder_data_t       feeder_data_inst;
    srama_addr_t               fed_entry_srama_addr;
    a_arr_data_t               a_arr;
    srama_data_t               srama_data;

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
    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.ifmaps_cfg_shared);
        ifmaps_model.configure(computation_params.core_ifmaps_params,
                               computation_params.ifmaps_rows_active);
    endtask

    function write_ifmaps_feeder_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_info);
        if (ifmaps_feeder_info.feeder_clear && ifmaps_feeder_info.clearfifo) begin
            ifmaps_model.reset_model();
        end
    endfunction

    function write_ifmaps_feeder_srama_access_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_srama_access_info);
        feeder_data_inst.srama_addr = ifmaps_feeder_srama_access_info.srama_addr;
        feeder_data_inst.srama_data = ifmaps_feeder_srama_access_info.srama_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMA Access Addr: 0x%0h Data: 0x%0h",
        ifmaps_feeder_srama_access_info.srama_addr ,ifmaps_feeder_srama_access_info.srama_data))
        
        check_srama_rd_addr(feeder_data_inst.srama_addr);
        ifmaps_model.add_ifmaps_sram_access(feeder_data_inst);
        
        if (ifmaps_feeder_srama_access_info.til_done) check_tile_done_counters();
    endfunction 

    function write_ifmaps_feeder_arr_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_arr_info);
        
        ifmaps_model.add_ifmaps_systolic_feed_data(ifmaps_feeder_arr_info.a_arr);
        if(ifmaps_model.has_valid_entry())
            check_ifmaps_fed_data();
    
        if(!ifmaps_feeder_arr_info.pop_en) 
            ifmaps_model.clear_arr_byte_valids();
            
    endfunction

    virtual function void check_srama_rd_addr(srama_addr_t srama_rd_addr);
        if (ifmaps_model.get_next_exp_srama_rd_addr() != srama_rd_addr)
            `sauria_error(message_id, $sformatf("SRAMA_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",  
        ifmaps_model.get_next_exp_srama_rd_addr(), srama_rd_addr))
    endfunction

    virtual function void check_ifmaps_fed_data();
        fed_entry_srama_addr = ifmaps_model.get_valid_entry_srama_addr();
        srama_data           = ifmaps_model.get_valid_srama_data();
        a_arr                = ifmaps_model.get_valid_a_arr_data();
        
        if (srama_data != a_arr) 
            `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMA Read Data Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    fed_entry_srama_addr ,srama_data, a_arr ))
                
    endfunction

    virtual function void check_tile_done_counters();
        if (!(ifmaps_model.get_c_idx() == srama_addr_t'(0) && 
              ifmaps_model.get_x_idx() == srama_addr_t'(0) && 
              ifmaps_model.get_y_idx() == srama_addr_t'(0)))
            `sauria_error(message_id, $sformatf("Tile Done Condition And Counters Mismatch C_IDX: 0x%0h X_IDX: 0x%0h Y_IDX: 0x%0h", 
              ifmaps_model.get_c_idx(), ifmaps_model.get_x_idx(), ifmaps_model.get_y_idx()))
    endfunction

endclass
