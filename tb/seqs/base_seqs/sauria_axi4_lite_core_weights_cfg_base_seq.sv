class sauria_axi4_lite_core_weights_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_weights_cfg_base_seq)

    sauria_computation_params    computation_params;

    rand sauria_axi4_lite_data_t weights_w_lim;
    rand sauria_axi4_lite_data_t weights_w_step;
    rand sauria_axi4_lite_data_t weights_k_lim;
                          
    rand sauria_axi4_lite_data_t weights_k_step;
    rand sauria_axi4_lite_data_t weights_tile_k_lim;
                        
    rand sauria_axi4_lite_data_t weights_tile_k_step;
    rand sauria_axi4_lite_data_t weights_cols_active;
                         
    rand sauria_axi4_lite_data_t weights_aligned_flag;
    
    constraint weights_dimensions_c{
        weights_w_lim  == sauria_axi4_lite_data_t'('h0);
        weights_k_lim  == sauria_axi4_lite_data_t'('h0);
    }
           
    constraint weights_dimension_steps {
        weights_k_step == sauria_axi4_lite_data_t'('h0);
        weights_w_step == sauria_axi4_lite_data_t'('h0);
    }

    constraint weights_tile_dimensions_c{
        weights_tile_k_lim == sauria_axi4_lite_data_t'('h0);
    }
              
    constraint weights_tile_dimension_steps_c{
        weights_tile_k_step == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint weights_aligned_flag_c{
        weights_aligned_flag == sauria_axi4_lite_data_t'('h0);
    }

    constraint weights_active_cols_c{
        weights_cols_active == sauria_axi4_lite_data_t'('h0);
    }

    function new(string name="sauria_axi4_lite_core_weights_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_WEIGHTS_CFG_BASE_SEQ";
    
        queue_start_idx = CORE_WEIGHTS_CFG_CRs_START_IDX;
        queue_end_idx   = CORE_WEIGHTS_CFG_CRs_END_IDX;

        if (!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_core_weights_cfg_base_seq")
    endfunction

    virtual task body();
        get_weights_params();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_core_weights_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_core_weights_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            33: begin
                set_weights_w_lim();
                set_weights_w_step();
            end
            34: begin
                set_weights_k_lim();
                set_weights_k_step();
            end
            35: begin
                set_weights_tile_k_lim();
                set_weights_tile_k_step();
            end
            36: begin
                set_weights_cols_active();
                set_weights_aligned_flag();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
           
    endfunction

    virtual task get_weights_params();

        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        wait(computation_params.shared);
       
        weights_w_lim       = computation_params.weights_w_lim;        
        weights_k_lim       = computation_params.weights_K;         
       
        weights_w_step      = computation_params.weights_w_step; 
        weights_k_step      = computation_params.weights_k_step;  
       
        weights_tile_k_lim  = computation_params.tile_weights_K;     
        weights_tile_k_step = computation_params.tile_weights_k_step; 

        `sauria_info(message_id, $sformatf("K_Step: 0x%0h K_Lim: 0x%0h Tile_K_Step: 0x%0h Tile_K_Lim: 0x%0h ", 
                    weights_k_step, weights_k_lim, weights_tile_k_step, weights_tile_k_lim))
    endtask
                
    virtual function void set_weights_w_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = weights_w_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_weights_w_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = weights_w_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_weights_k_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = weights_k_lim;
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_weights_k_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = weights_k_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_weights_tile_k_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = weights_tile_k_lim;
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_weights_tile_k_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = weights_tile_k_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_weights_cols_active();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = weights_cols_active;
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_weights_aligned_flag();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[16] = weights_aligned_flag;
        set_cfg_cr_data(wdata);
    endfunction
    
endclass