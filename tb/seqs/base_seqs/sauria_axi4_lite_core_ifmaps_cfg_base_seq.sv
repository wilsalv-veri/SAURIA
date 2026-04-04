import sauria_cfg_pkg::*;

class sauria_axi4_lite_core_ifmaps_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_ifmaps_cfg_base_seq)

    uvm_status_e                  status;
    sauria_core_ifmaps_reg_block  core_ifmaps_reg_block;

    sauria_axi4_lite_data_t ifmaps_x_lim;
    sauria_axi4_lite_data_t ifmaps_x_step;
    
    sauria_axi4_lite_data_t ifmaps_y_step;
    sauria_axi4_lite_data_t ifmaps_y_lim;
                          
    sauria_axi4_lite_data_t ifmaps_ch_step;
    sauria_axi4_lite_data_t ifmaps_ch_lim;
                           
    sauria_axi4_lite_data_t ifmaps_tile_x_step;
    sauria_axi4_lite_data_t ifmaps_tile_x_lim;
                         
    sauria_axi4_lite_data_t ifmaps_tile_y_step;
    sauria_axi4_lite_data_t ifmaps_tile_y_lim;
    
    rand logic[63:0]             dilation_pattern;
                              
    rand sauria_axi4_lite_data_t ifmaps_rows_active;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_0;
                             
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_1;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_2;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_3;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_4;
                            
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_5;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_6;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_7;
   
    constraint dilation_pattern_c{
        if(DV_GEMM_BYPASS){
            dilation_pattern == 64'h8000000000000000;
        }
        else {
            dilation_pattern == 64'h0;
        }
        
    }
        
    constraint ifmaps_loc_woffs_c{
        ifmaps_loc_woffs_0 == sauria_axi4_lite_data_t'('h0);                         
        ifmaps_loc_woffs_1 == sauria_axi4_lite_data_t'('h1);
        ifmaps_loc_woffs_2 == sauria_axi4_lite_data_t'('h2);
        ifmaps_loc_woffs_3 == sauria_axi4_lite_data_t'('h3);
        ifmaps_loc_woffs_4 == sauria_axi4_lite_data_t'('h4);          
        ifmaps_loc_woffs_5 == sauria_axi4_lite_data_t'('h5);
        ifmaps_loc_woffs_6 == sauria_axi4_lite_data_t'('h6);
        ifmaps_loc_woffs_7 == sauria_axi4_lite_data_t'('h7);
    }

    constraint ifmpas_active_inactive_rows_c{
        ifmaps_rows_active == sauria_axi4_lite_data_t'('hff);
    }

    function new(string name="sauria_axi4_lite_core_ifmaps_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_IFMAPS_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.core_ifmaps_reg_block = subsystem_reg_block.core_ifmaps_reg_block;
    endtask

    virtual task body();
        get_ifmaps_params();
        share_ifmaps_cfg();
        super.body();
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        set_core_ifmaps_cfg_CRs();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        send_ifmaps_core_cfg_CRs();
    endtask

    virtual function void set_core_ifmaps_cfg_CRs();
        set_core_ifmaps_cfg_reg_24();
        set_core_ifmaps_cfg_reg_25();
        set_core_ifmaps_cfg_reg_26();
        set_core_ifmaps_cfg_reg_27();
        set_core_ifmaps_cfg_reg_28();
        set_core_ifmaps_cfg_reg_29();
        set_core_ifmaps_cfg_reg_30();
        set_core_ifmaps_cfg_reg_31();
        set_core_ifmaps_cfg_reg_32();
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_24();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_24.ifmaps_x_lim.set(ifmaps_x_lim);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_24.ifmaps_x_step.set(ifmaps_x_step);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_24.ifmaps_y_lim_lower.set(ifmaps_y_lim[SEQ_IFMAPS_Y_LIM_LOWER_MSB:SEQ_IFMAPS_Y_LIM_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_25();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_25.ifmaps_y_lim.set(ifmaps_y_lim[ACT_TILE_DIM_SIZE:SEQ_IFMAPS_Y_LIM_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_25.ifmaps_y_step.set(ifmaps_y_step);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_25.ifmaps_ch_lim_lower.set(ifmaps_ch_lim[SEQ_IFMAPS_CH_LIM_LOWER_MSB:SEQ_IFMAPS_CH_LIM_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_26();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_26.ifmaps_ch_lim.set(ifmaps_ch_lim[ACT_TILE_DIM_SIZE:SEQ_IFMAPS_CH_LIM_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_26.ifmaps_ch_step.set(ifmaps_ch_step);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_26.ifmaps_tile_x_lim_lower.set(ifmaps_tile_x_lim[SEQ_IFMAPS_TILE_X_LIM_LOWER_MSB:SEQ_IFMAPS_TILE_X_LIM_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_27();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_27.ifmaps_tile_x_lim.set(ifmaps_tile_x_lim[ACT_TILE_DIM_SIZE:SEQ_IFMAPS_TILE_X_LIM_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_27.ifmaps_tile_x_step.set(ifmaps_tile_x_step);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_27.ifmaps_tile_y_lim_lower.set(ifmaps_tile_y_lim[SEQ_IFMAPS_TILE_Y_LIM_LOWER_MSB:SEQ_IFMAPS_TILE_Y_LIM_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_28();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_28.ifmaps_tile_y_lim.set(ifmaps_tile_y_lim[ACT_TILE_DIM_SIZE:SEQ_IFMAPS_TILE_Y_LIM_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_28.ifmaps_tile_y_step.set(ifmaps_tile_y_step);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_28.dilation_pattern_lower.set(dilation_pattern[SEQ_IFMAPS_DIL_PATTERN_LOWER_MSB:SEQ_IFMAPS_DIL_PATTERN_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_29();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_29.dilation_pattern_second_byte.set(dilation_pattern[SEQ_IFMAPS_DIL_PATTERN_2ND_MSB:SEQ_IFMAPS_DIL_PATTERN_2ND_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_30();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_30.dilation_pattern_upper.set(dilation_pattern[SEQ_IFMAPS_DIL_PATTERN_MSB:SEQ_IFMAPS_DIL_PATTERN_UPPER_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_30.ifmaps_rows_active.set(ifmaps_rows_active);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_30.ifmaps_loc_woffs_0_lower.set(ifmaps_loc_woffs_0[SEQ_IFMAPS_LOC_WOFFS_0_LOWER_MSB:SEQ_IFMAPS_LOC_WOFFS_0_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_31();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.ifmaps_loc_woffs_0.set(ifmaps_loc_woffs_0[SEQ_IFMAPS_LOC_WOFFS_MSB:SEQ_IFMAPS_LOC_WOFFS_0_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.ifmaps_loc_woffs_1.set(ifmaps_loc_woffs_1);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.ifmaps_loc_woffs_2.set(ifmaps_loc_woffs_2);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.ifmaps_loc_woffs_3.set(ifmaps_loc_woffs_3);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.ifmaps_loc_woffs_4_lower.set(ifmaps_loc_woffs_4[SEQ_IFMAPS_LOC_WOFFS_4_LOWER_MSB:SEQ_IFMAPS_LOC_WOFFS_4_LOWER_LSB]);
    endfunction

    virtual function void set_core_ifmaps_cfg_reg_32();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_32.ifmaps_loc_woffs_4.set(ifmaps_loc_woffs_4[SEQ_IFMAPS_LOC_WOFFS_MSB:SEQ_IFMAPS_LOC_WOFFS_4_LSB]);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_32.ifmaps_loc_woffs_5.set(ifmaps_loc_woffs_5);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_32.ifmaps_loc_woffs_6.set(ifmaps_loc_woffs_6);
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_32.ifmaps_loc_woffs_7.set(ifmaps_loc_woffs_7);
    endfunction

    virtual task send_ifmaps_core_cfg_CRs();
        core_ifmaps_reg_block.core_ifmaps_cfg_reg_24.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_24")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_25.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_25")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_26.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_26")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_27.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_27")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_28.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_28")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_29.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_29")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_30.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_30")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_31.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_31")

        core_ifmaps_reg_block.core_ifmaps_cfg_reg_32.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating core_ifmaps_cfg_reg_32")
    endtask

    virtual task get_ifmaps_params();

        wait_comp_params_shared();
       
        ifmaps_ch_step = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_c_step;                
        ifmaps_ch_lim  = ifmaps_ch_step * computation_params.df_controller_ifmaps_params.tile_params.ifmaps_C;             

        ifmaps_x_step  = SRAMA_N;                     
        ifmaps_x_lim   = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_X;   
                                                                          
        ifmaps_y_step  = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_y_step;  
        ifmaps_y_lim   = ifmaps_y_step * computation_params.df_controller_ifmaps_params.tile_params.ifmaps_Y;          
        
        //Single Tile
        ifmaps_tile_x_step = ifmaps_ch_lim;             
        ifmaps_tile_x_lim  = ifmaps_ch_lim;       
        
        ifmaps_tile_y_step = ifmaps_ch_lim;            
        ifmaps_tile_y_lim  = ifmaps_ch_lim;             
    endtask

    virtual task share_ifmaps_cfg();
        
        computation_params.core_ifmaps_params.tile_params.ifmaps_x_step 
                    = ifmaps_x_step; 
        computation_params.core_ifmaps_params.tile_params.ifmaps_X      
                    = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_X;
        
        computation_params.core_ifmaps_params.tile_params.ifmaps_y_step 
                    = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_y_step; 
        computation_params.core_ifmaps_params.tile_params.ifmaps_Y      
                    = ifmaps_y_lim;

        computation_params.core_ifmaps_params.tile_params.ifmaps_c_step 
                    = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_c_step; 
        computation_params.core_ifmaps_params.tile_params.ifmaps_C           
                    = ifmaps_ch_lim;  

        computation_params.core_ifmaps_params.tensor_params.tile_ifmaps_x_step 
                    = ifmaps_tile_x_step;
        computation_params.core_ifmaps_params.tensor_params.tile_ifmaps_X
                    = ifmaps_tile_x_lim;  

        computation_params.core_ifmaps_params.tensor_params.tile_ifmaps_y_step 
                    = ifmaps_tile_y_step;  
        computation_params.core_ifmaps_params.tensor_params.tile_ifmaps_Y      
                    = ifmaps_tile_y_lim;  
        

        computation_params.ifmaps_rows_active = ifmaps_rows_active;
        computation_params.ifmaps_cfg_shared  = 1'b1;
    endtask

endclass