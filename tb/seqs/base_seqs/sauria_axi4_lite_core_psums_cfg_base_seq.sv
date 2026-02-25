class sauria_axi4_lite_core_psums_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_psums_cfg_base_seq)

    sauria_computation_params    computation_params;

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
        psums_reps == sauria_axi4_lite_data_t'('h0);
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

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_core_psums_cfg_base_seq")
    endfunction

    virtual task body();
        get_psums_params();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_core_psums_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_core_psums_cfg_CRs(int cfg_cr_idx);
        
        case(cfg_cr_idx)
            37: begin
                set_psums_reps();
                set_psums_cx_lim();
                set_psums_cx_step_lower();
            end
            38: begin
                set_psums_cx_step_upper();
                set_psums_ck_lim();
                set_psums_ck_step_lower();
            end
            39: begin
                set_psums_ck_step_upper();
                set_psums_tile_cy_lim();
                set_psums_tile_cy_step_lower(); 
            end
            40: begin
                set_psums_tile_cy_step_upper(); 
                set_psums_tile_ck_lim();
                set_psums_tile_ck_step();  
                set_psums_inactive_cols_lower();
            end
            41: begin
                set_psums_inactive_cols_upper();  
                set_psums_preload_en();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
        
    endfunction

    virtual task get_psums_params();
       
        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        wait(computation_params.shared);
        psums_reps        = computation_params.psums_K;
        
        psums_cx_step     = computation_params.psums_cx_step;
        psums_cx_lim      = computation_params.psums_CX;          
        //psums_reps        = computation_params.psums_X;//(computation_params.psums_Y * computation_params.psums_K); //computation_params.psums_X
                            //* computation_params.tile_X * computation_params.tile_Y 
                            //* computation_params.tile_C * computation_params.tile_K;
                            
        psums_ck_step       = computation_params.psums_ck_step;  
        psums_ck_lim        = computation_params.psums_CK;        
        
        psums_tile_cy_step  = computation_params.tile_psums_cy_step;
        psums_tile_cy_lim   = computation_params.tile_psums_CY; 
        
        psums_tile_ck_step  = computation_params.tile_psums_ck_step;
        psums_tile_ck_lim   = computation_params.tile_psums_CK; 
    endtask
  
    virtual function void set_psums_reps();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[13:0] = psums_reps;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_cx_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[27:14] = psums_cx_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_cx_step_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:28] = psums_cx_step[3:0];
        set_cfg_cr_data(wdata);
    endfunction
           
    virtual function void set_psums_cx_step_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[9:0] = psums_cx_step[13:4];
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_psums_ck_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[23:10] = psums_ck_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_ck_step_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:24] = psums_ck_step[7:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_ck_step_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[5:0] = psums_ck_step[13:8];
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_psums_tile_cy_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[19:6] = psums_tile_cy_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_tile_cy_step_lower(); 
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:20] = psums_tile_cy_step[11:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_tile_cy_step_upper(); 
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[1:0] = psums_tile_cy_step[13:12];
        set_cfg_cr_data(wdata);
    endfunction
    
                
    virtual function void set_psums_tile_ck_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:2] = psums_tile_ck_lim;
        set_cfg_cr_data(wdata);
    endfunction 

    virtual function void set_psums_tile_ck_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:16] = psums_tile_ck_step;
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_psums_inactive_cols_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = psums_inactive_cols[1:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_inactive_cols_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[5:0] = psums_inactive_cols[7:2];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_preload_en();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[6] = psums_preload_en;
        set_cfg_cr_data(wdata);
    endfunction

endclass