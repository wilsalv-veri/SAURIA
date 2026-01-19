class sauria_axi4_lite_dma_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_dma_controller_cfg_base_seq)

    sauria_axi_vseqr                   vseqr;

    `uvm_declare_p_sequencer(uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item))
    
    sauria_computation_params          computation_params;

    rand sauria_axi4_lite_data_t       dma_tile_x_lim;
    rand sauria_axi4_lite_data_t       dma_tile_y_lim;

    rand sauria_axi4_lite_data_t       dma_tile_c_lim;
    rand sauria_axi4_lite_data_t       dma_tile_k_lim;

    rand sauria_axi4_lite_data_t       dma_tile_psums_x_step;
    rand sauria_axi4_lite_data_t       dma_tile_psums_y_step;
    rand sauria_axi4_lite_data_t       dma_tile_psums_k_step;
    rand sauria_axi4_lite_data_t       dma_tile_ifmaps_x_step;
    rand sauria_axi4_lite_data_t       dma_tile_ifmaps_y_step;
    rand sauria_axi4_lite_data_t       dma_tile_ifmaps_c_step;
    rand sauria_axi4_lite_data_t       dma_tile_weights_k_step;
    rand sauria_axi4_lite_data_t       dma_tile_weights_c_step;
    rand sauria_axi4_lite_data_t       dma_ifmaps_y_lim;
    rand sauria_axi4_lite_data_t       dma_ifmaps_c_lim;
    rand sauria_axi4_lite_data_t       dma_psums_y_step;
    rand sauria_axi4_lite_data_t       dma_psums_k_step;
    rand sauria_axi4_lite_data_t       dma_ifmaps_y_step;
    rand sauria_axi4_lite_data_t       dma_ifmaps_c_step;

    rand sauria_axi4_lite_data_t       dma_weights_w_step;
    rand sauria_axi4_lite_data_t       dma_ifmaps_ett;
    
     constraint dma_ifmaps_tile_dimensions_c{
        dma_tile_x_lim == sauria_axi4_lite_data_t'('h0);
        dma_tile_y_lim == sauria_axi4_lite_data_t'('h0);
    }

    constraint dma_weights_tile_dimensions_c {
        dma_tile_c_lim == sauria_axi4_lite_data_t'('h0);
        dma_tile_k_lim == sauria_axi4_lite_data_t'('h0);
    }

    constraint dma_psums_tile_dimension_steps_c {
        dma_tile_psums_x_step == sauria_axi4_lite_data_t'('h0);
        dma_tile_psums_y_step == sauria_axi4_lite_data_t'('h0);
        dma_tile_psums_k_step == sauria_axi4_lite_data_t'('h0);
    }

    constraint dma_ifmaps_tile_dimension_steps_c {
        dma_tile_ifmaps_x_step == sauria_axi4_lite_data_t'('h0);
        dma_tile_ifmaps_y_step == sauria_axi4_lite_data_t'('h0);
        dma_tile_ifmaps_c_step == sauria_axi4_lite_data_t'('h0);
    }
       
    constraint dma_weights_tile_dimension_steps_c {
        dma_tile_weights_k_step == sauria_axi4_lite_data_t'('h0);
        dma_tile_weights_c_step == sauria_axi4_lite_data_t'('h0);
    }
        
    constraint dma_weights_dimension_steps_c {
        dma_weights_w_step     == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint dma_ifmaps_dimensions_c {
        dma_ifmaps_y_lim == sauria_axi4_lite_data_t'('h0);
        dma_ifmaps_c_lim == sauria_axi4_lite_data_t'('h0);
        dma_ifmaps_ett   == sauria_axi4_lite_data_t'('h0);
    } 
       
    constraint dma_psums_dimension_steps_c {
        dma_psums_y_step == sauria_axi4_lite_data_t'('h0);
        dma_psums_k_step == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint dma_ifmaps_dimension_steps{
        dma_ifmaps_y_step == sauria_axi4_lite_data_t'('h0);
        dma_ifmaps_c_step == sauria_axi4_lite_data_t'('h0);
    }
   
    function new(string name="sauria_axi4_lite_dma_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_DMA_CONTROLLER_CFG_BASE_SEQ";
   
        queue_start_idx =  DMA_CONTROLLER_CFG_CRs_START_IDX;
        queue_end_idx   =  DMA_CONTROLLER_CFG_CRs_END_IDX;

        if (!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_dma_cfg_base_seq")
    endfunction

    virtual task body();
        share_computation_params();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_dma_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void share_computation_params();
        `sauria_info(message_id, $sformatf("Sharing Computation Params X: %0d Y: %0d C: %0d",dma_ifmaps_ett, dma_ifmaps_y_lim, dma_ifmaps_c_lim))
        
        if (!uvm_config_db #(sauria_computation_params)::get(p_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        computation_params.ifmap_X = dma_ifmaps_ett;
        computation_params.ifmap_Y = dma_ifmaps_y_lim;
        computation_params.ifmap_C = dma_ifmaps_c_lim;
        computation_params.shared  = 1'b1;
    endfunction

    virtual function void add_dma_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            0: begin
                set_dma_tile_x_lim();
                set_dma_tile_y_lim();
            end
            1: begin
                set_dma_tile_c_lim();
                set_dma_tile_k_lim();
            end
            2:  set_dma_tile_psums_x_step();
            3:  set_dma_tile_psums_y_step();
            4:  set_dma_tile_psums_k_step();
            5:  set_dma_tile_ifmaps_x_step();
            6:  set_dma_tile_ifmaps_y_step();
            7:  set_dma_tile_ifmaps_c_step();
            8:  set_dma_tile_weights_k_step();
            9:  set_dma_tile_weights_c_step();
            10: set_dma_ifmaps_y_lim();
            11: set_dma_ifmaps_c_lim();
            12: set_dma_psums_y_step();
            13: set_dma_psums_k_step();
            14: set_dma_ifmaps_y_step();
            15: set_dma_ifmaps_c_step();
            16: set_dma_weights_w_step();
            17: set_dma_ifmaps_ett();
            
        endcase  
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;

    endfunction
    
    virtual function void set_dma_tile_x_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = dma_tile_x_lim;
        set_cfg_cr_data(wdata);
    endfunction 

    virtual function void set_dma_tile_y_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = dma_tile_y_lim;
        set_cfg_cr_data(wdata);
    endfunction 
   
    virtual function void set_dma_tile_c_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = dma_tile_c_lim;
        set_cfg_cr_data(wdata);
    endfunction 

    virtual function void set_dma_tile_k_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = dma_tile_k_lim;
        set_cfg_cr_data(wdata);
    endfunction 
    
    virtual function void set_dma_tile_psums_x_step();
        set_cfg_cr_data(dma_tile_psums_x_step);
    endfunction
    
    virtual function void set_dma_tile_psums_y_step();
        set_cfg_cr_data(dma_tile_psums_y_step);
    endfunction
    
    virtual function void set_dma_tile_psums_k_step();
        set_cfg_cr_data(dma_tile_psums_k_step);
    endfunction

    virtual function void set_dma_tile_ifmaps_x_step();
        set_cfg_cr_data(dma_tile_ifmaps_x_step);
    endfunction
    
    virtual function void set_dma_tile_ifmaps_y_step();
        set_cfg_cr_data(dma_tile_ifmaps_y_step);
    endfunction
    
    virtual function void set_dma_tile_ifmaps_c_step();
        set_cfg_cr_data(dma_tile_ifmaps_c_step);
    endfunction

    virtual function void set_dma_tile_weights_k_step();
        set_cfg_cr_data(dma_tile_weights_k_step);
    endfunction
    
    virtual function void set_dma_tile_weights_c_step();
        set_cfg_cr_data(dma_tile_weights_c_step);
    endfunction

    virtual function void set_dma_ifmaps_y_lim();
        set_cfg_cr_data(dma_ifmaps_y_lim);
    endfunction

    virtual function void set_dma_ifmaps_c_lim();
        set_cfg_cr_data(dma_ifmaps_c_lim);
    endfunction

    virtual function void set_dma_psums_y_step();
        set_cfg_cr_data(dma_psums_y_step);
    endfunction
    
    virtual function void set_dma_psums_k_step();
        set_cfg_cr_data(dma_psums_k_step);
    endfunction

    virtual function void set_dma_ifmaps_y_step();
        set_cfg_cr_data(dma_ifmaps_y_step);
    endfunction

    virtual function void set_dma_ifmaps_c_step();
        set_cfg_cr_data(dma_ifmaps_c_step);
    endfunction

    virtual function void set_dma_weights_w_step();
        set_cfg_cr_data(dma_weights_w_step);
    endfunction
    
    virtual function void set_dma_ifmaps_ett();
        set_cfg_cr_data(dma_ifmaps_ett);
    endfunction

endclass