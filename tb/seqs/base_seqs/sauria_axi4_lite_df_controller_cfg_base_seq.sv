class sauria_axi4_lite_df_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_df_controller_cfg_base_seq)
   
    sauria_computation_params          computation_params;

    rand bit                           stand_alone;
    rand bit                           stand_alone_keep_A;
    rand bit                           stand_alone_keep_B;
    rand bit                           stand_alone_keep_C;    
    
    rand sauria_axi4_lite_data_t       start_SRAMA_addr;
    rand sauria_axi4_lite_data_t       start_SRAMB_addr;
    rand sauria_axi4_lite_data_t       start_SRAMC_addr;

    rand sauria_axi4_lite_data_t       loop_order;
    rand bit                           Cw_eq;
    rand bit                           Ch_eq;
    rand bit                           Ck_eq;
    rand bit                           WXfer_op;
    
    sauria_axi4_lite_data_t            ifmaps_size;
    sauria_axi4_lite_data_t            weights_size;
    sauria_axi4_lite_data_t            psums_size;
    
    constraint stand_alone_cfg_c {
        stand_alone        == 1'b1;
        stand_alone_keep_A == 1'b1;
        stand_alone_keep_B == 1'b1;
        stand_alone_keep_C == 1'b1;  
    }

    constraint srams_starting_addrs_c {
        solve start_SRAMA_addr before start_SRAMB_addr;
        solve start_SRAMB_addr before start_SRAMC_addr;

        start_SRAMA_addr == MEM_BASE_OFFSET;
        start_SRAMB_addr == start_SRAMA_addr + 'h1000_0000;
        start_SRAMC_addr == start_SRAMB_addr + 'h1000_0000; 
    }
    
    constraint eq_flags_c {
        Cw_eq == 1'b0;
        Ch_eq == 1'b0;
        Ck_eq == 1'b0;
    }

    constraint loop_order_c {
        loop_order == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint wxfer_op_c {
        WXfer_op == 1'b0;
    }
   
    function new(string name="sauria_axi4_lite_df_controller_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_DF_CONTROLLER_CFG_BASE_SEQ";
        enable_done_interrupt = 1'b1;
        queue_start_idx       =  DF_CONTROLLER_CFG_CRs_START_IDX;
        queue_end_idx         =  DF_CONTROLLER_CFG_CRs_END_IDX;

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_df_controller_cfg_base_seq")
        
    endfunction

    virtual task body();
        exchange_computation_params();
        
        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_df_controller_cfg_base_seq")
        
        super.body();
    endtask

    virtual task exchange_computation_params();
        get_computation_params_access();
        set_starting_tensors_addr();
        get_tensor_sizes();
    endtask

    virtual function void get_computation_params_access();
         if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    endfunction

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_df_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_df_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            18: set_start_SRAMA_addr();
            19: set_start_SRAMB_addr();
            20: set_start_SRAMC_addr();
            21: begin
                clear_start();
                set_loop_order();
                set_stand_alone_mode();
                set_Cw_eq();
                set_Ch_eq();
                set_Ck_eq();
                set_WXfer_op();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;

    endfunction

    virtual task get_tensor_sizes();
        wait(computation_params.shared);
        ifmaps_size  = computation_params.get_ifmaps_size();
        weights_size = computation_params.get_weights_size();
        psums_size   = computation_params.get_psums_size();
    endtask

    virtual task set_starting_tensors_addr();
        computation_params.start_SRAMA_addr = start_SRAMA_addr;
        computation_params.start_SRAMB_addr = start_SRAMB_addr;
        computation_params.start_SRAMC_addr = start_SRAMC_addr;
        computation_params.tensors_start_addr_shared = 1'b1;
    endtask
    
    virtual function void clear_start();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[22] = 1'b1; //!start
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_stand_alone_mode();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[18] = stand_alone;
        wdata[19] = stand_alone_keep_A;
        wdata[20] = stand_alone_keep_B;
        wdata[21] = stand_alone_keep_C;   
        
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_start_SRAMA_addr();
        set_cfg_cr_data(start_SRAMA_addr);
    endfunction

    virtual function void set_start_SRAMB_addr();
        set_cfg_cr_data(start_SRAMB_addr);
    endfunction

    virtual function void set_start_SRAMC_addr();
        set_cfg_cr_data(start_SRAMC_addr);
    endfunction

    virtual function void set_loop_order();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[17:16] = loop_order;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_Cw_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[23] = Cw_eq;
        set_cfg_cr_data(wdata);
    endfunction
   
    virtual function void set_Ch_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[24] = Ch_eq;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_Ck_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[25] = Ck_eq;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_WXfer_op();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31] = WXfer_op;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void randomize_without_srams_starting_addrs();
        turn_off_dependent_constraints();

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_df_controller_cfg_base_seq")
        
        turn_on_dependent_constraints();
    endfunction

    virtual function void randomize_with_srams_starting_addrs();
        turn_off_independent_constraints();

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_df_controller_cfg_base_seq")
        
        turn_on_independent_constraints();
    endfunction
    
    virtual function void turn_off_dependent_constraints();
        srams_starting_addrs_c.constraint_mode(0);
    endfunction

    virtual function void turn_off_independent_constraints();
        stand_alone_cfg_c.constraint_mode(0);
        eq_flags_c.constraint_mode(0);
        loop_order_c.constraint_mode(0); 
        wxfer_op_c.constraint_mode(0);
    endfunction

    virtual function void turn_on_dependent_constraints();
        srams_starting_addrs_c.constraint_mode(1);
    endfunction

    virtual function void turn_on_independent_constraints();
        stand_alone_cfg_c.constraint_mode(1);
        eq_flags_c.constraint_mode(1);
        loop_order_c.constraint_mode(1); 
        wxfer_op_c.constraint_mode(1);
    endfunction
    
endclass