class sauria_axi4_lite_dma_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_dma_controller_cfg_base_seq)

    `uvm_declare_p_sequencer(uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item))
    
    sauria_computation_params          computation_params;

    rand int X;
    rand int Y;
    rand int C;
    rand int K;
    rand int W;

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
    rand sauria_axi4_lite_data_t       dma_weights_w_lim;
    rand sauria_axi4_lite_data_t       dma_ifmaps_ett;
    
    //Independent Constraints
    constraint tile_dimensions_c {
      X == 0;
      Y == 0;
      W == 0;
      C == 0;
      K == 0;
    }

    constraint tensor_dimensions_c {
        dma_tile_x_lim          == sauria_axi4_lite_data_t'('h0);
        dma_tile_y_lim          == sauria_axi4_lite_data_t'('h0);
        dma_tile_c_lim          == sauria_axi4_lite_data_t'('h0); 
        dma_tile_k_lim          == sauria_axi4_lite_data_t'('h0); 
    }

    //Dependent Constraints
    constraint dma_ifmaps_c {
        solve dma_ifmaps_ett    before dma_ifmaps_y_step, dma_tile_ifmaps_x_step;
        solve dma_ifmaps_y_lim  before dma_tile_ifmaps_x_step;
        solve dma_ifmaps_c_lim  before dma_tile_ifmaps_x_step;
        solve dma_ifmaps_y_step before dma_ifmaps_c_step;
        
        dma_ifmaps_ett          == X; 
        dma_ifmaps_y_lim        == Y; 
        dma_ifmaps_c_lim        == C; 

        dma_ifmaps_y_step       == dma_ifmaps_ett*df_ctrl_pkg::A_BYTES;
        dma_ifmaps_c_step       == dma_ifmaps_y_step*(dma_ifmaps_y_lim+1);
       
        solve dma_tile_ifmaps_x_step before dma_tile_ifmaps_y_step;
        solve dma_tile_ifmaps_y_step before dma_tile_ifmaps_c_step;

        dma_tile_ifmaps_x_step  == dma_ifmaps_ett * (dma_ifmaps_y_lim + 1) * (dma_ifmaps_c_lim + 1);
        dma_tile_ifmaps_y_step  == dma_tile_ifmaps_x_step * (dma_tile_x_lim + 1);
        dma_tile_ifmaps_c_step  == dma_tile_ifmaps_y_step * (dma_tile_y_lim + 1); 
    }

    constraint dma_weights_c {

        solve dma_weights_w_lim before dma_tile_weights_c_step;
        solve dma_weights_w_step before dma_tile_weights_k_step, dma_weights_w_lim;
        
        dma_weights_w_step      == K; 
        dma_weights_w_lim       == C * dma_weights_w_step;
        
        dma_tile_weights_c_step == dma_weights_w_lim + dma_weights_w_step; 
        dma_tile_weights_k_step == dma_tile_weights_c_step * (dma_tile_c_lim + 1);
    }

    constraint dma_psums_c {
        solve dma_psums_y_step      before dma_psums_k_step;
        solve dma_psums_k_step      before dma_tile_psums_x_step;
        solve dma_tile_psums_x_step before dma_tile_psums_y_step;
        solve dma_tile_psums_y_step before dma_tile_psums_k_step;
       
        dma_psums_y_step        == dma_ifmaps_ett; 
        dma_psums_k_step        == dma_psums_y_step * (dma_ifmaps_y_lim+1);
    
        

        dma_tile_psums_x_step   == dma_psums_k_step * dma_weights_w_step; 
        dma_tile_psums_y_step   == dma_tile_psums_x_step * (dma_tile_x_lim + 1);
        dma_tile_psums_k_step   == dma_tile_psums_y_step * (dma_tile_y_lim + 1); 
    }
    
    function new(string name="sauria_axi4_lite_dma_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_DMA_CONTROLLER_CFG_BASE_SEQ";
   
        queue_start_idx =  DMA_CONTROLLER_CFG_CRs_START_IDX;
        queue_end_idx   =  DMA_CONTROLLER_CFG_CRs_END_IDX;

        //1) Get Tile Dimensions(X, Y, W, C, K) and Tensor Dimensions 
        //2) Set IFMAPS and WEIGHTS
        //3) Set PSUMS
        repeat(3) begin
            if (!this.randomize())
                `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_cfg_w_dma_base_seq")
        end
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
        
        share_tile_dimensions();
        share_ifmaps_params();
        share_weights_params();
        share_psums_params();
        computation_params.shared  = 1'b1;
    endfunction

    virtual function void share_tile_dimensions();
        computation_params.tile_X       = dma_tile_x_lim + 1;
        computation_params.tile_Y       = dma_tile_y_lim + 1;
        computation_params.tile_C       = dma_tile_c_lim + 1;
        computation_params.tile_K       = dma_tile_k_lim + 1;
    endfunction

    virtual function void share_ifmaps_params();
        computation_params.ifmaps_X            = dma_ifmaps_ett;
        computation_params.ifmaps_Y            = dma_ifmaps_y_lim;
        computation_params.ifmaps_C            = dma_ifmaps_c_lim;

        computation_params.ifmaps_x_step       = df_ctrl_pkg::A_BYTES;
        computation_params.ifmaps_y_step       = dma_ifmaps_y_step;
        computation_params.ifmaps_c_step       = dma_ifmaps_c_step;

        computation_params.tile_ifmaps_X       = dma_tile_x_lim;
        computation_params.tile_ifmaps_Y       = dma_tile_y_lim;

        computation_params.tile_ifmaps_x_step  = dma_tile_ifmaps_x_step;
        computation_params.tile_ifmaps_y_step  = dma_tile_ifmaps_y_step;
    endfunction

    virtual function void share_weights_params();
        computation_params.weights_W           = dma_tile_weights_c_step / dma_weights_w_step; 
        computation_params.weights_K           = dma_weights_w_step;           
       
        computation_params.weights_w_step      = dma_weights_w_step;
        computation_params.weights_k_step      = df_ctrl_pkg::B_BYTES;
       
        computation_params.tile_weights_c_step = dma_tile_weights_c_step;
        computation_params.tile_weights_k_step = dma_tile_weights_k_step;
    
        computation_params.tile_weights_K      = dma_tile_k_lim; 
    endfunction

    virtual function void share_psums_params();
         
        computation_params.psums_K             = dma_weights_w_step;
        computation_params.psums_Y             = dma_ifmaps_y_lim;
        computation_params.psums_X             = dma_ifmaps_ett;
        
        computation_params.tile_psums_x_step   = dma_tile_psums_x_step;
        //computation_params.psums_CX          = 
        //computation_params.psums_cx_step     = 
       
        computation_params.psums_CK            = dma_tile_weights_k_step - 1;
        computation_params.psums_ck_step       = dma_psums_k_step;
       
        //computation_params.tile_psums_CY     = 
        computation_params.tile_psums_cy_step  = dma_tile_psums_y_step;
    
        //computation_params.tile_psums_CK     = 
        computation_params.tile_psums_ck_step  = dma_tile_psums_k_step;
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