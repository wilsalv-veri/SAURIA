class sauria_axi4_lite_core_psums_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_psums_cfg_base_seq)

    uvm_status_e status;

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
    
        start_controller_fsm = 1'b1;
        queue_start_idx      = CORE_PSUMS_CFG_CRs_START_IDX;
        queue_end_idx        = CORE_PSUMS_CFG_CRs_END_IDX;

    endfunction

    virtual task body();
        get_psums_params();
        share_psums_cfg();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        set_core_psums_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void set_core_psums_cfg_CRs(int cfg_cr_idx);
        
        case(cfg_cr_idx)
            37: set_core_psums_cfg_reg_37();
            38: set_core_psums_cfg_reg_38();
            39: set_core_psums_cfg_reg_39();
            40: set_core_psums_cfg_reg_40();
            41: set_core_psums_cfg_reg_41();
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
        
    endfunction

    virtual function void set_core_psums_cfg_reg_37();
        core_psums_reg_block.core_psums_cfg_reg_37.psums_reps.set(psums_reps);
        core_psums_reg_block.core_psums_cfg_reg_37.psums_cx_lim.set(psums_cx_lim);
        core_psums_reg_block.core_psums_cfg_reg_37.psums_cx_step_lower.set(psums_cx_step[SEQ_PSUMS_CX_STEP_LOWER_MSB:SEQ_PSUMS_CX_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_38();
        core_psums_reg_block.core_psums_cfg_reg_38.psums_cx_step.set(psums_cx_step[PSUMS_TILE_DIM_SIZE:SEQ_PSUMS_CX_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_38.psums_ck_lim.set(psums_ck_lim);
        core_psums_reg_block.core_psums_cfg_reg_38.psums_ck_step_lower.set(psums_ck_step[SEQ_PSUMS_CK_STEP_LOWER_MSB:SEQ_PSUMS_CK_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_39();
        core_psums_reg_block.core_psums_cfg_reg_39.psums_ck_step.set(psums_ck_step[PSUMS_TILE_DIM_SIZE:SEQ_PSUMS_CK_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_39.psums_tile_cy_lim.set(psums_tile_cy_lim);
        core_psums_reg_block.core_psums_cfg_reg_39.psums_tile_cy_step_lower.set(psums_tile_cy_step[SEQ_PSUMS_TILE_CY_STEP_LOWER_MSB:SEQ_PSUMS_TILE_CY_STEP_LOWER_LSB]);
    endfunction

    virtual function void set_core_psums_cfg_reg_40();
        core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_cy_step.set(psums_tile_cy_step[PSUMS_TILE_DIM_SIZE:SEQ_PSUMS_TILE_CY_STEP_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_ck_lim.set(psums_tile_ck_lim);
        if (FP_ARITHMETIC) begin
            core_psums_reg_block.core_psums_cfg_reg_40.psums_tile_ck_step_lower.set(psums_tile_ck_step[SEQ_PSUMS_TILE_CK_STEP_LOWER_MSB:SEQ_PSUMS_TILE_CK_STEP_LOWER_LSB]);
        end
        if (INT_ARITHMETIC) begin
            core_psums_reg_block.core_psums_cfg_reg_40.psums_inactive_cols_lower.set(psums_inactive_cols[SEQ_PSUMS_INACTIVE_COLS_LOWER_MSB:SEQ_PSUMS_INACTIVE_COLS_LOWER_LSB]);
        end
    endfunction

    virtual function void set_core_psums_cfg_reg_41();
        if (FP_ARITHMETIC) begin
            core_psums_reg_block.core_psums_cfg_reg_41.psums_tile_ck_step.set(psums_tile_ck_step[PSUMS_TILE_DIM_SIZE:SEQ_PSUMS_TILE_CK_STEP_LSB]); //Only for FP
        end
        core_psums_reg_block.core_psums_cfg_reg_41.psums_inactive_cols.set(psums_inactive_cols[COLS_ACTIVE_SIZE-1:SEQ_PSUMS_INACTIVE_COLS_LSB]);
        core_psums_reg_block.core_psums_cfg_reg_41.psums_preload_en.set(psums_preload_en);
    endfunction

    virtual task send_psums_cfg_CRs();
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
  
    //--------------------37-------------------------
    virtual function void set_psums_reps();
        //INT
        //wdata[13:0] = psums_reps;
    endfunction

    virtual function void set_psums_cx_lim();
        //INT
        //wdata[27:14] = psums_cx_lim;
    endfunction

    virtual function void set_psums_cx_step_lower();
        //INT
        //wdata[31:28] = psums_cx_step[3:0];
    endfunction
    
    //--------------------38-------------------------
    virtual function void set_psums_cx_step_upper();
        //INT
        //wdata[9:0] = psums_cx_step[13:4];
    endfunction
    
    virtual function void set_psums_ck_lim();
        //INT
        //wdata[23:10] = psums_ck_lim;
    endfunction

    virtual function void set_psums_ck_step_lower();
        //INT
        //wdata[31:24] = psums_ck_step[7:0];
    endfunction

    //--------------------39-------------------------
    virtual function void set_psums_ck_step_upper();
        //INT
        //wdata[5:0] = psums_ck_step[13:8];
    endfunction
                
    virtual function void set_psums_tile_cy_lim();
        //INT
        //wdata[19:6] = psums_tile_cy_lim;
    endfunction

    virtual function void set_psums_tile_cy_step_lower(); 
        //INT
        //wdata[31:20] = psums_tile_cy_step[11:0];
    endfunction

    //--------------------40-------------------------
    virtual function void set_psums_tile_cy_step_upper(); 
        //INT
        //wdata[1:0] = psums_tile_cy_step[13:12];
    endfunction
    
                
    virtual function void set_psums_tile_ck_lim();
        //INT
        //wdata[15:2] = psums_tile_ck_lim;
     endfunction 

    virtual function void set_psums_tile_ck_step();
        //INT
        //wdata[29:16] = psums_tile_ck_step;
    endfunction

    //--------------------41-------------------------
    virtual function void set_psums_tile_ck_step_upper();
        //INT
        //wdata[29:16] = psums_tile_ck_step;
    endfunction
    
    //Only for INT
    virtual function void set_psums_inactive_cols_lower();
        //INT
        //wdata[31:30] = psums_inactive_cols[1:0];
    endfunction

    virtual function void set_psums_inactive_cols_upper();
        //INT
        //wdata[5:0] = psums_inactive_cols[7:2];
    endfunction

    virtual function void set_psums_preload_en();
        //INT
        //wdata[6] = psums_preload_en;
    endfunction

endclass