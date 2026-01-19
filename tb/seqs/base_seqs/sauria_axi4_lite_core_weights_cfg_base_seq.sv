class sauria_axi4_lite_core_weights_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_weights_cfg_base_seq)

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

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_core_weights_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_core_weights_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            32: begin
                set_weights_w_lim();
                set_weights_w_step();
                set_weights_k_lim();
            end
            33: begin
                set_weights_k_step();
                set_weights_tile_k_lim();
            end
            34: begin
                set_weights_tile_k_step();
                set_weights_cols_active();
            end
            35: begin
                set_weights_aligned_flag();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
           
    endfunction
                
    virtual function void set_weights_w_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_weights_w_step();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_weights_k_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_weights_k_step();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_weights_tile_k_lim();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_weights_tile_k_step();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction

    virtual function void set_weights_cols_active();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
                
    virtual function void set_weights_aligned_flag();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
    
endclass