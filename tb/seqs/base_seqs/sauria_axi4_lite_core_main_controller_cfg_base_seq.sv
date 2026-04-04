class sauria_axi4_lite_core_main_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_main_controller_cfg_base_seq)

    uvm_status_e                           status;
    sauria_core_main_controller_reg_block  core_main_controller_reg_block;

    sauria_axi4_lite_data_t total_macs;
    sauria_axi4_lite_data_t act_reps;                    
    sauria_axi4_lite_data_t weight_reps;
    
    rand sauria_axi4_lite_data_t zero_negligence_threshold;                
   
    constraint zero_neg_c{
        zero_negligence_threshold == sauria_axi4_lite_data_t'('h0);                
    }

    function new(string name="sauria_axi4_lite_core_main_controller_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_MAIN_CONTROLLER_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.core_main_controller_reg_block = subsystem_reg_block.core_main_controller_reg_block;
    endtask

    virtual task body();
        share_main_controller_cfg();
        super.body();
    endtask

    virtual task share_main_controller_cfg();
        wait_comp_params_shared();
        total_macs  = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_C;
        act_reps    = computation_params.df_controller_weights_params.tile_params.weights_K / SRAMB_N;
        weight_reps = (computation_params.df_controller_ifmaps_params.tile_params.ifmaps_X 
                        * computation_params.df_controller_ifmaps_params.tile_params.ifmaps_Y) 
                        / SRAMA_N;

        computation_params.act_reps = act_reps;
        computation_params.wei_reps = weight_reps;
        computation_params.incntlim = total_macs;
        computation_params.main_controller_cfg_shared = 1'b1;
    endtask
  
    virtual function void set_unit_specific_cfg_CRs();
        set_core_main_controller_cfg_CRs();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        send_main_controller_cfg_CRs();
    endtask

    virtual function void set_core_main_controller_cfg_CRs();
        set_core_main_controller_cfg_reg_22();
        set_core_main_controller_cfg_reg_23();
    endfunction

    virtual function void set_core_main_controller_cfg_reg_22();
        core_main_controller_reg_block.core_main_controller_cfg_reg_22.total_macs.set(total_macs);
        core_main_controller_reg_block.core_main_controller_cfg_reg_22.act_reps.set(act_reps);
        core_main_controller_reg_block.core_main_controller_cfg_reg_22.weight_reps_lower.set(weight_reps[SEQ_MAIN_WEIGHT_REPS_LOWER_MSB:SEQ_MAIN_WEIGHT_REPS_LOWER_LSB]);
    endfunction

    virtual function void set_core_main_controller_cfg_reg_23();
        core_main_controller_reg_block.core_main_controller_cfg_reg_23.weight_reps_upper.set(weight_reps[SEQ_MAIN_WEIGHT_REPS_UPPER_MSB:SEQ_MAIN_WEIGHT_REPS_UPPER_LSB]);
        core_main_controller_reg_block.core_main_controller_cfg_reg_23.zero_negligence_threshold.set(zero_negligence_threshold);
    endfunction

    virtual task send_main_controller_cfg_CRs();
        core_main_controller_reg_block.core_main_controller_cfg_reg_22.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_main_controller_cfg_reg_22")

        core_main_controller_reg_block.core_main_controller_cfg_reg_23.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_main_controller_cfg_reg_23")
    endtask
   
endclass