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
        psums_reps == sauria_axi4_lite_data_t'('h1);
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
        psums_preload_en == sauria_axi4_lite_data_t'('h0);
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
            36: begin
                set_psums_reps();
                set_psums_cx_lim();
                set_psums_cx_step_lower();
            end
            37: begin
                set_psums_cx_step_upper();
                set_psums_ck_lim();
                set_psums_ck_step();
            end
            38: begin
                set_psums_tile_cy_lim();
                set_psums_tile_cy_step(); 
            end
            39: begin
                `sauria_info(message_id, "Got here")
                set_psums_tile_ck_lim();
                set_psums_tile_ck_step();
                `sauria_info(message_id, "Got here2")
               
            end
            40: begin
                set_psums_inactive_cols();
                set_psums_preload_en();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
        
    endfunction

    virtual task get_psums_params();
       
        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        wait(computation_params.shared);
     
        //psums_cx_lim      = computation_params.psums_CX;          
        //psums_cx_step     = computation_params.psums_cx_step;     
       
        psums_ck_lim        = computation_params.psums_CK;        
        psums_ck_step       = computation_params.psums_ck_step;  
       
        //psums_tile_cy_lim = computation_params.tile_psums_CY; 
        psums_tile_cy_step  = computation_params.tile_psums_cy_step;
    
        //psums_tile_ck_lim = computation_params.tile_psums_CK; 
        psums_tile_ck_step  = computation_params.tile_psums_ck_step;
    endtask
  
    virtual function void set_psums_reps();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[14:0] = psums_reps;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_cx_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:15] = psums_cx_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_psums_cx_step_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = psums_cx_step[1:0];
        set_cfg_cr_data(wdata);
    endfunction
           
    virtual function void set_psums_cx_step_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[12:0] = psums_cx_step[14:2];
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_psums_ck_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_psums_ck_step();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_psums_tile_cy_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_psums_tile_cy_step(); 
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_psums_tile_ck_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction 

    virtual function void set_psums_tile_ck_step();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_psums_inactive_cols();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_psums_preload_en();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

endclass