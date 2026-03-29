class sauria_axi4_lite_core_psums_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_psums_cfg_base_seq)

    uvm_status_e                 status;
    sauria_core_psums_reg_block  core_psums_reg_block;

    rand sauria_axi4_lite_data_t psums_reps;
    rand sauria_axi4_lite_data_t psums_cx_lim;
    rand sauria_axi4_lite_data_t psums_cx_step;
                       
    rand sauria_axi4_lite_data_t psums_ck_lim;
    rand sauria_axi4_lite_data_t psums_ck_step;
        
    rand sauria_axi4_lite_data_t psums_tile_cy_lim;
    rand sauria_axi4_lite_data_t psums_tile_cy_step; 
         
    rand sauria_axi4_lite_data_t psums_tile_ck_lim;
    rand sauria_axi4_lite_data_t psums_tile_ck_step;
         
    rand sauria_axi4_lite_data_t psums_inactive_cols;
    rand sauria_axi4_lite_data_t psums_preload_en;
  
    constraint psums_reps_c{
        psums_reps == sauria_axi4_lite_data_t'('h3);
    }

    constraint psums_dimensions_c{
        psums_cx_lim == sauria_axi4_lite_data_t'('h0);
        psums_ck_lim == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint psums_dimension_steps_c{
        psums_cx_step == sauria_axi4_lite_data_t'('h0);                   
        psums_ck_step == sauria_axi4_lite_data_t'('h0);
    }
        
    constraint psums_tile_dimensions_c{
        psums_tile_cy_lim == sauria_axi4_lite_data_t'('h0);   
        psums_tile_ck_lim == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint psums_tile_dimension_steps_c{
        psums_tile_cy_step == sauria_axi4_lite_data_t'('h0); 
        psums_tile_ck_step == sauria_axi4_lite_data_t'('h0);
    }
         
    constraint psums_preload_en_c{
        psums_preload_en == sauria_axi4_lite_data_t'('h1);
    }
    
    constraint psums_inactive_cols_c{
        psums_inactive_cols == sauria_axi4_lite_data_t'('h0);
    }

    function new(string name="sauria_axi4_lite_core_psums_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_PSUMS_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.core_psums_reg_block = subsystem_reg_block.core_psums_reg_block;
    endtask

    virtual task body();
        get_psums_params();
        share_psums_cfg();
        super.body();
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        set_core_psums_cfg_CRs();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        send_psums_core_cfg_CRs();
    endtask

    virtual function void set_core_psums_cfg_CRs();
        set_core_psums_cfg_reg_37();
        set_core_psums_cfg_reg_38();
        set_core_psums_cfg_reg_39();
        set_core_psums_cfg_reg_40();
        set_core_psums_cfg_reg_41();
    endfunction

    virtual function void set_core_psums_cfg_reg_37();
        core_psums_reg_block.core_psums_cfg_reg_37.psums_reps.set(psums_reps);
        core_psums_reg_block.core_psums_cfg_reg_37.psums_cx_lim.set(psums_cx_lim);
        core_psums_reg_block.core_psums_cfg_reg_37.psums_cx_step_lower.set(psums_cx_step[SEQ_PSUMS_CX_STEP_LOWER_MSB:SEQ_PSUMS_CX_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_38();
        core_psums_reg_block.core_psums_cfg_reg_38.psums_cx_step.set(psums_cx_step[SEQ_PSUMS_CX_STEP_MSB:SEQ_PSUMS_CX_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_38.psums_ck_lim.set(psums_ck_lim);
        core_psums_reg_block.core_psums_cfg_reg_38.psums_ck_step_lower.set(psums_ck_step[SEQ_PSUMS_CK_STEP_LOWER_MSB:SEQ_PSUMS_CK_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_39();
        core_psums_reg_block.core_psums_cfg_reg_39.psums_ck_step.set(psums_ck_step[SEQ_PSUMS_CK_STEP_MSB:SEQ_PSUMS_CK_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_39.psums_tile_cy_lim.set(psums_tile_cy_lim);
        core_psums_reg_block.core_psums_cfg_reg_39.psums_tile_cy_step_lower.set(psums_tile_cy_step[SEQ_PSUMS_TILE_CY_STEP_LOWER_MSB:SEQ_PSUMS_TILE_CY_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_40();
        core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_cy_step.set(psums_tile_cy_step[SEQ_PSUMS_TILE_CY_STEP_MSB:SEQ_PSUMS_TILE_CY_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_ck_lim.set(psums_tile_ck_lim);
        core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_ck_step_lower.set(psums_tile_ck_step[SEQ_PSUMS_TILE_CK_STEP_LOWER_MSB:SEQ_PSUMS_TILE_CK_STEP_LOWER_LSB]);
        
        if (INT_ARITHMETIC) begin
            core_psums_reg_block.core_psums_cfg_reg_40.psums_inactive_cols_lower.set(psums_inactive_cols[SEQ_PSUMS_INACTIVE_COLS_LOWER_MSB:SEQ_PSUMS_INACTIVE_COLS_LOWER_LSB]);
        end
    endfunction

    virtual function void set_core_psums_cfg_reg_41();
        if (FP_ARITHMETIC) begin
            core_psums_reg_block.core_psums_cfg_reg_41.psums_tile_ck_step.set(psums_tile_ck_step[SEQ_PSUMS_TILE_CK_STEP_MSB:SEQ_PSUMS_TILE_CK_STEP_LSB]); //Only for FP
        end
        core_psums_reg_block.core_psums_cfg_reg_41.psums_inactive_cols.set(psums_inactive_cols[SEQ_PSUMS_INACTIVE_COLS_MSB:SEQ_PSUMS_INACTIVE_COLS_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_41.psums_preload_en.set(psums_preload_en);
    endfunction

    virtual task send_psums_core_cfg_CRs();
        core_psums_reg_block.core_psums_cfg_reg_37.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_psums_cfg_reg_37")

        core_psums_reg_block.core_psums_cfg_reg_38.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_psums_cfg_reg_38")

        core_psums_reg_block.core_psums_cfg_reg_39.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_psums_cfg_reg_39")

        core_psums_reg_block.core_psums_cfg_reg_40.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_psums_cfg_reg_40")

        core_psums_reg_block.core_psums_cfg_reg_41.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_psums_cfg_reg_41")
    endtask

    virtual task get_psums_params();

        wait_comp_params_shared();

        psums_cx_step       = computation_params.psums_cx_step;
        psums_cx_lim        = computation_params.psums_CX;          
                            
        psums_ck_step       = computation_params.psums_ck_step;  
        psums_ck_lim        = computation_params.psums_CK;        
        
        psums_tile_cy_step  = computation_params.tile_psums_cy_step;
        psums_tile_cy_lim   = computation_params.tile_psums_CY; 
        
        psums_tile_ck_step  = computation_params.tile_psums_ck_step;
        psums_tile_ck_lim   = computation_params.tile_psums_CK; 
    endtask

    virtual task share_psums_cfg();
        computation_params.psums_preload_en     = psums_preload_en;
        computation_params.psums_inactive_cols  = psums_inactive_cols;
        computation_params.psums_mgr_cfg_shared = 1'b1;
    endtask
  
endclass