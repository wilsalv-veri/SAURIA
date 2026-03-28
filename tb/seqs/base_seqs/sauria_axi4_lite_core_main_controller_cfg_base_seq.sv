class sauria_axi4_lite_core_main_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_main_controller_cfg_base_seq)

    uvm_status_e status;
   
    rand sauria_axi4_lite_data_t total_macs;
    rand sauria_axi4_lite_data_t act_reps;
                        
    rand sauria_axi4_lite_data_t weight_reps;
    
    rand sauria_axi4_lite_data_t zero_negligence_threshold;                
   
    
    constraint total_macs_c {
        total_macs == sauria_axi4_lite_data_t'('h10);
    }
    
    constraint array_reps_c {
        act_reps    == sauria_axi4_lite_data_t'('h1);                    
        weight_reps == sauria_axi4_lite_data_t'('h1);
    }
   
    constraint zero_neg_c{
        zero_negligence_threshold == sauria_axi4_lite_data_t'('h0);                
    }

    function new(string name="sauria_axi4_lite_core_main_controller_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_MAIN_CONTROLLER_CFG_BASE_SEQ";
        
        queue_start_idx = CORE_MAIN_CONTROLLER_CFG_CRs_START_IDX;
        queue_end_idx   = CORE_MAIN_CONTROLLER_CFG_CRs_END_IDX;

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_core_main_controller_cfg_base_seq")
    endfunction

    virtual task body();
        set_total_macs_params();
        super.body();
    endtask

    virtual task set_total_macs_params();
        wait_comp_params_shared();
        
        computation_params.incntlim = total_macs;
        computation_params.main_controller_cfg_shared = 1'b1;
    endtask
  
    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        set_core_main_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void set_core_main_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            22: set_core_main_controller_cfg_reg_22();
            23: set_core_main_controller_cfg_reg_23();
        endcase
      
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