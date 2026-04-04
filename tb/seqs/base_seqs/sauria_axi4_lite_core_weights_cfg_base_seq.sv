class sauria_axi4_lite_core_weights_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_weights_cfg_base_seq)

    uvm_status_e                   status;
    sauria_core_weights_reg_block  core_weights_reg_block;

    sauria_axi4_lite_data_t weights_w_lim;
    sauria_axi4_lite_data_t weights_w_step;
    sauria_axi4_lite_data_t weights_k_lim;
                          
    sauria_axi4_lite_data_t weights_k_step;
    sauria_axi4_lite_data_t weights_tile_k_lim;
                        
    sauria_axi4_lite_data_t weights_tile_k_step;
    
    rand sauria_axi4_lite_data_t weights_cols_active;                     
    rand sauria_axi4_lite_data_t weights_aligned_flag;
    
    constraint weights_aligned_flag_c{
        weights_aligned_flag == sauria_axi4_lite_data_t'('h1);
    }

    constraint weights_active_cols_c{
        weights_cols_active == sauria_axi4_lite_data_t'('hffff);
    }

    function new(string name="sauria_axi4_lite_core_weights_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_WEIGHTS_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.core_weights_reg_block = subsystem_reg_block.core_weights_reg_block;
    endtask

    virtual task body();
        get_weights_params();
        share_weights_cfg();
        super.body();
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        set_core_weights_cfg_CRs();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        send_core_weights_cfg_CRs();
    endtask

    virtual function void set_core_weights_cfg_CRs();
        set_core_weights_cfg_reg_33();
        set_core_weights_cfg_reg_34();
        set_core_weights_cfg_reg_35();
        set_core_weights_cfg_reg_36();
    endfunction

    virtual task get_weights_params();
    
        wait_comp_params_shared();

        weights_w_step      = computation_params.df_controller_weights_params.tile_params.weights_w_step;                           
        weights_w_lim       = computation_params.df_controller_weights_params.tile_params.weights_C;           

        weights_k_step      = SRAMB_N;
        weights_k_lim       = computation_params.df_controller_weights_params.tile_params.weights_K;      

        //Single Tile
        weights_tile_k_step = weights_w_lim; 
        weights_tile_k_lim  = weights_w_lim;                
    endtask

    
    virtual task share_weights_cfg();    

        computation_params.core_weights_params.tile_params.weights_w_step 
                        = computation_params.df_controller_weights_params.tile_params.weights_w_step; 

        computation_params.core_weights_params.tile_params.weights_C 
                        = computation_params.df_controller_weights_params.tile_params.weights_C;
        
        
        computation_params.core_weights_params.tile_params.weights_k_step 
                        = weights_k_step; 
 

        computation_params.core_weights_params.tile_params.weights_K 
                        = computation_params.df_controller_weights_params.tile_params.weights_K; 

           
        computation_params.core_weights_params.tensor_params.tile_weights_k_step 
                        = weights_tile_k_step;
        
        computation_params.core_weights_params.tensor_params.tile_weights_K 
                        = weights_tile_k_lim;
        
        computation_params.weights_cols_active = weights_cols_active;
        computation_params.weights_cfg_shared = 1'b1;
    endtask

    virtual task send_core_weights_cfg_CRs();
        core_weights_reg_block.core_weights_cfg_reg_33.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_weights_cfg_reg_33")
        
        core_weights_reg_block.core_weights_cfg_reg_34.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_weights_cfg_reg_34")
        
        core_weights_reg_block.core_weights_cfg_reg_35.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_weights_cfg_reg_35")
        
        core_weights_reg_block.core_weights_cfg_reg_36.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_weights_cfg_reg_36")
        
    endtask

    virtual function void set_core_weights_cfg_reg_33();
        core_weights_reg_block.core_weights_cfg_reg_33.weights_w_lim.set(weights_w_lim);
        core_weights_reg_block.core_weights_cfg_reg_33.weights_w_step.set(weights_w_step);
        if (FP_ARITHMETIC) begin
            core_weights_reg_block.core_weights_cfg_reg_33.weights_k_lim_lower.set(weights_k_lim[SEQ_WEIGHTS_K_LIM_LOWER_MSB:SEQ_WEIGHTS_K_LIM_LOWER_LSB]);
        end
    endfunction

    virtual function void set_core_weights_cfg_reg_34();
        core_weights_reg_block.core_weights_cfg_reg_34.weights_k_lim.set(weights_k_lim[SEQ_WEIGHTS_K_LIM_MSB:SEQ_WEIGHTS_K_LIM_LSB]);
        core_weights_reg_block.core_weights_cfg_reg_34.weights_k_step.set(weights_k_step);
        if (FP_ARITHMETIC) begin
            core_weights_reg_block.core_weights_cfg_reg_34.weights_tile_k_lim_lower.set(weights_tile_k_lim[SEQ_WEIGHTS_TILE_K_LIM_LOWER_MSB:SEQ_WEIGHTS_TILE_K_LIM_LOWER_LSB]);
        end
    endfunction
    
    virtual function void set_core_weights_cfg_reg_35();
        core_weights_reg_block.core_weights_cfg_reg_35.weights_tile_k_lim.set(weights_tile_k_lim[SEQ_WEIGHTS_TILE_K_LIM_MSB:SEQ_WEIGHTS_TILE_K_LIM_LSB]);
        core_weights_reg_block.core_weights_cfg_reg_35.weights_tile_k_step.set(weights_tile_k_step);
        if (FP_ARITHMETIC) begin
            core_weights_reg_block.core_weights_cfg_reg_35.weights_cols_active_lower.set(weights_cols_active[SEQ_WEIGHTS_ACTIVE_COLS_LOWER_MSB:SEQ_WEIGHTS_ACTIVE_COLS_LOWER_LSB]);
        end
    endfunction

    virtual function void set_core_weights_cfg_reg_36();
        core_weights_reg_block.core_weights_cfg_reg_36.weights_cols_active.set(weights_cols_active[SEQ_WEIGHTS_ACTIVE_COLS_MSB:SEQ_WEIGHTS_ACTIVE_COLS_LSB]);
        core_weights_reg_block.core_weights_cfg_reg_36.weights_aligned_flag.set(weights_aligned_flag);
    endfunction

endclass