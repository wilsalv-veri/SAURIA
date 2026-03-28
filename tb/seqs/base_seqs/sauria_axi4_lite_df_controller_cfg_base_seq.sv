class sauria_axi4_lite_df_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_df_controller_cfg_base_seq)

    uvm_status_e                        status;
   
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
        start_SRAMA_addr == START_SRAMA_MEM_ADDR;
        start_SRAMB_addr == START_SRAMB_MEM_ADDR;
        start_SRAMC_addr == START_SRAMC_MEM_ADDR; 
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
        super.body();
    endtask

    virtual task exchange_computation_params();
        set_compute_params_loop_order();
        set_starting_tensors_addr();
        set_tensor_modifiers();
        get_tensor_sizes();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_df_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_df_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            18: set_df_controller_cfg_reg_18();
            19: set_df_controller_cfg_reg_19();
            20: set_df_controller_cfg_reg_20();
            21: set_df_controller_cfg_reg_21();
        endcase

    endfunction

    virtual task send_df_controller_cfg_CRs();
        df_controller_reg_block.df_controller_cfg_reg_18.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating df_controller_cfg_reg_18")

        df_controller_reg_block.df_controller_cfg_reg_19.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating df_controller_cfg_reg_19")

        df_controller_reg_block.df_controller_cfg_reg_20.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating df_controller_cfg_reg_20")

        df_controller_reg_block.df_controller_cfg_reg_21.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating df_controller_cfg_reg_21")
    endtask

    virtual task get_tensor_sizes();
        wait_comp_params_shared();

        ifmaps_size  = computation_params.get_ifmaps_size();
        weights_size = computation_params.get_weights_size();
        psums_size   = computation_params.get_psums_size();
    endtask

    virtual function void set_starting_tensors_addr();
        computation_params.start_SRAMA_addr = start_SRAMA_addr;
        computation_params.start_SRAMB_addr = start_SRAMB_addr;
        computation_params.start_SRAMC_addr = start_SRAMC_addr;
        computation_params.tensors_start_addr_shared = 1'b1;
    endfunction

    virtual function void set_compute_params_loop_order();
        computation_params.loop_order = loop_order;
    endfunction

    virtual function void set_tensor_modifiers();
        computation_params.Cw_eq    = Cw_eq;
        computation_params.Ch_eq    = Ch_eq;
        computation_params.Ck_eq    = Ck_eq;
        computation_params.WXfer_op = WXfer_op;
    endfunction

    virtual function void set_df_controller_cfg_reg_18();
        df_controller_reg_block.df_controller_cfg_reg_18.start_srama_addr.set(start_SRAMA_addr);
    endfunction

    virtual function void set_df_controller_cfg_reg_19();
        df_controller_reg_block.df_controller_cfg_reg_19.start_sramb_addr.set(start_SRAMB_addr);
    endfunction

    virtual function void set_df_controller_cfg_reg_20();
        df_controller_reg_block.df_controller_cfg_reg_20.start_sramc_addr.set(start_SRAMC_addr);
    endfunction

    virtual function void set_df_controller_cfg_reg_21();
        df_controller_reg_block.df_controller_cfg_reg_21.start.set(1'b0);
        df_controller_reg_block.df_controller_cfg_reg_21.loop_order.set(loop_order);
        df_controller_reg_block.df_controller_cfg_reg_21.stand_alone.set(stand_alone);
        df_controller_reg_block.df_controller_cfg_reg_21.stand_alone_keep_a.set(stand_alone_keep_A);
        df_controller_reg_block.df_controller_cfg_reg_21.stand_alone_keep_b.set(stand_alone_keep_B);
        df_controller_reg_block.df_controller_cfg_reg_21.stand_alone_keep_c.set(stand_alone_keep_C);
        df_controller_reg_block.df_controller_cfg_reg_21.cw_eq.set(Cw_eq);
        df_controller_reg_block.df_controller_cfg_reg_21.ch_eq.set(Ch_eq);
        df_controller_reg_block.df_controller_cfg_reg_21.ck_eq.set(Ck_eq);
        df_controller_reg_block.df_controller_cfg_reg_21.wxfer_op.set(WXfer_op);
    endfunction

endclass