class sauria_axi4_lite_dma_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_dma_controller_cfg_base_seq)

    `uvm_declare_p_sequencer(uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item))

    uvm_status_e                        status;
    
    //sauria_computation_params          computation_params;

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
        
        dma_ifmaps_ett          == 128;//X; 
        dma_ifmaps_y_lim        == Y - 1; 
        dma_ifmaps_c_lim        == C - 1; 

        dma_ifmaps_y_step       == dma_ifmaps_ett; //*df_ctrl_pkg::A_BYTES;
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
        
        dma_weights_w_step      == 256; //K; 
        dma_weights_w_lim       == (C-1) * dma_weights_w_step;
        
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

    endfunction

    virtual task body();
        share_computation_params();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_dma_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void share_computation_params();  
        share_tile_dimensions();
        share_ifmaps_params();
        share_weights_params();
        share_psums_params();
        `sauria_info(message_id, $sformatf("Sharing Computation Params X: %0d Y: %0d C: %0d",computation_params.ifmaps_X, computation_params.ifmaps_Y, computation_params.ifmaps_C))
        
        computation_params.shared  = 1'b1;
    endfunction

    virtual function void share_tile_dimensions();
        computation_params.tile_X       = dma_tile_x_lim + 1;
        computation_params.tile_Y       = dma_tile_y_lim + 1;
        computation_params.tile_C       = dma_tile_c_lim + 1;
        computation_params.tile_K       = dma_tile_k_lim + 1;
    endfunction

    virtual function void share_ifmaps_params();
        computation_params.ifmaps_x_step       = df_ctrl_pkg::A_BYTES;
        computation_params.ifmaps_X            = dma_ifmaps_ett;
        
        computation_params.ifmaps_y_step       = dma_ifmaps_y_step;
        computation_params.ifmaps_Y            = dma_ifmaps_y_lim + 1;
        
        computation_params.ifmaps_c_step       = dma_ifmaps_c_step;
        computation_params.ifmaps_C            = dma_ifmaps_c_lim + 1;

        //Single Tile Computation
        computation_params.tile_ifmaps_x_step  = dma_tile_ifmaps_x_step;
        computation_params.tile_ifmaps_X       = dma_tile_ifmaps_x_step; 
    
        computation_params.tile_ifmaps_y_step  = dma_tile_ifmaps_x_step; 
        computation_params.tile_ifmaps_Y       = dma_tile_ifmaps_x_step; 
    endfunction

    virtual function void share_weights_params();

        computation_params.weights_k_step      = df_ctrl_pkg::B_BYTES;
        computation_params.weights_K           = dma_weights_w_step;           
       
        computation_params.weights_w_step      = dma_weights_w_step;
        computation_params.weights_w_lim       = dma_tile_weights_c_step;
        computation_params.weights_W           = dma_tile_weights_c_step / dma_weights_w_step; //Rest Use here
        
        //Single Tile Computation 
        computation_params.tile_weights_c_step = dma_tile_weights_c_step;
        
        computation_params.tile_weights_k_step = dma_tile_weights_c_step;
        computation_params.tile_weights_K      = dma_tile_weights_c_step;
    endfunction

    virtual function void share_psums_params();
        
        //Golden Model Use
        computation_params.psums_K             = dma_weights_w_step;
        computation_params.psums_Y             = dma_ifmaps_y_lim + 1;
        computation_params.psums_X             = dma_ifmaps_ett;
        
        computation_params.tile_psums_x_step   = dma_tile_psums_x_step;
       
        //Core Use
        computation_params.psums_cx_step       = SRAMC_N;
        computation_params.psums_CX            = computation_params.psums_cx_step;
        
        computation_params.psums_ck_step       = computation_params.psums_CX; 
        computation_params.psums_CK            = computation_params.psums_ck_step * X; 
        
        //Single Tile
        computation_params.tile_psums_cy_step  = computation_params.psums_CK; 
        computation_params.tile_psums_CY       = computation_params.psums_CK * 3; 
        
        computation_params.tile_psums_ck_step  = computation_params.tile_psums_CY; 
        computation_params.tile_psums_CK       = computation_params.tile_psums_CY; 
    
    endfunction

    virtual function void add_dma_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            0:  set_dma_controller_cfg_reg_0();
            1:  set_dma_controller_cfg_reg_1();
            2:  set_dma_controller_cfg_reg_2();
            3:  set_dma_controller_cfg_reg_3();
            4:  set_dma_controller_cfg_reg_4();
            5:  set_dma_controller_cfg_reg_5();
            6:  set_dma_controller_cfg_reg_6();
            7:  set_dma_controller_cfg_reg_7();
            8:  set_dma_controller_cfg_reg_8();
            9:  set_dma_controller_cfg_reg_9();
            10: set_dma_controller_cfg_reg_10();
            11: set_dma_controller_cfg_reg_11();
            12: set_dma_controller_cfg_reg_12();
            13: set_dma_controller_cfg_reg_13();
            14: set_dma_controller_cfg_reg_14();
            15: set_dma_controller_cfg_reg_15();
            16: set_dma_controller_cfg_reg_16();
            17: set_dma_controller_cfg_reg_17();
        endcase  

    endfunction

    virtual task send_dma_controller_cfg_CRs();
        dma_controller_reg_block.dma_controller_cfg_reg_0.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_0")

        dma_controller_reg_block.dma_controller_cfg_reg_1.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_1")

        dma_controller_reg_block.dma_controller_cfg_reg_2.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_2")

        dma_controller_reg_block.dma_controller_cfg_reg_3.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_3")

        dma_controller_reg_block.dma_controller_cfg_reg_4.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_4")

        dma_controller_reg_block.dma_controller_cfg_reg_5.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_5")

        dma_controller_reg_block.dma_controller_cfg_reg_6.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_6")

        dma_controller_reg_block.dma_controller_cfg_reg_7.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_7")

        dma_controller_reg_block.dma_controller_cfg_reg_8.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_8")

        dma_controller_reg_block.dma_controller_cfg_reg_9.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_9")

        dma_controller_reg_block.dma_controller_cfg_reg_10.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_10")

        dma_controller_reg_block.dma_controller_cfg_reg_11.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_11")

        dma_controller_reg_block.dma_controller_cfg_reg_12.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_12")

        dma_controller_reg_block.dma_controller_cfg_reg_13.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_13")

        dma_controller_reg_block.dma_controller_cfg_reg_14.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_14")

        dma_controller_reg_block.dma_controller_cfg_reg_15.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_15")

        dma_controller_reg_block.dma_controller_cfg_reg_16.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_16")

        dma_controller_reg_block.dma_controller_cfg_reg_17.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while updating dma_controller_cfg_reg_17")
    endtask
    
    virtual function void set_dma_controller_cfg_reg_0();
        dma_controller_reg_block.dma_controller_cfg_reg_0.dma_tile_x_lim.set(to_reg_data(dma_tile_x_lim & sauria_axi4_lite_data_t'('h0000ffff)));
        dma_controller_reg_block.dma_controller_cfg_reg_0.dma_tile_y_lim.set(to_reg_data(dma_tile_y_lim & sauria_axi4_lite_data_t'('h0000ffff)));
    endfunction

    virtual function void set_dma_controller_cfg_reg_1();
        dma_controller_reg_block.dma_controller_cfg_reg_1.dma_tile_c_lim.set(to_reg_data(dma_tile_c_lim & sauria_axi4_lite_data_t'('h0000ffff)));
        dma_controller_reg_block.dma_controller_cfg_reg_1.dma_tile_k_lim.set(to_reg_data(dma_tile_k_lim & sauria_axi4_lite_data_t'('h0000ffff)));
    endfunction

    virtual function void set_dma_controller_cfg_reg_2();
        dma_controller_reg_block.dma_controller_cfg_reg_2.dma_tile_psums_x_step.set(to_reg_data(dma_tile_psums_x_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_3();
        dma_controller_reg_block.dma_controller_cfg_reg_3.dma_tile_psums_y_step.set(to_reg_data(dma_tile_psums_y_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_4();
        dma_controller_reg_block.dma_controller_cfg_reg_4.dma_tile_psums_k_step.set(to_reg_data(dma_tile_psums_k_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_5();
        dma_controller_reg_block.dma_controller_cfg_reg_5.dma_tile_ifmaps_x_step.set(to_reg_data(dma_tile_ifmaps_x_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_6();
        dma_controller_reg_block.dma_controller_cfg_reg_6.dma_tile_ifmaps_y_step.set(to_reg_data(dma_tile_ifmaps_y_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_7();
        dma_controller_reg_block.dma_controller_cfg_reg_7.dma_tile_ifmaps_c_step.set(to_reg_data(dma_tile_ifmaps_c_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_8();
        dma_controller_reg_block.dma_controller_cfg_reg_8.dma_tile_weights_k_step.set(to_reg_data(dma_tile_weights_k_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_9();
        dma_controller_reg_block.dma_controller_cfg_reg_9.dma_tile_weights_c_step.set(to_reg_data(dma_tile_weights_c_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_10();
        dma_controller_reg_block.dma_controller_cfg_reg_10.dma_ifmaps_y_lim.set(to_reg_data(dma_ifmaps_y_lim));
    endfunction

    virtual function void set_dma_controller_cfg_reg_11();
        dma_controller_reg_block.dma_controller_cfg_reg_11.dma_ifmaps_c_lim.set(to_reg_data(dma_ifmaps_c_lim));
    endfunction

    virtual function void set_dma_controller_cfg_reg_12();
        dma_controller_reg_block.dma_controller_cfg_reg_12.dma_psums_y_step.set(to_reg_data(dma_psums_y_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_13();
        dma_controller_reg_block.dma_controller_cfg_reg_13.dma_psums_k_step.set(to_reg_data(dma_psums_k_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_14();
        dma_controller_reg_block.dma_controller_cfg_reg_14.dma_ifmaps_y_step.set(to_reg_data(dma_ifmaps_y_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_15();
        dma_controller_reg_block.dma_controller_cfg_reg_15.dma_ifmaps_c_step.set(to_reg_data(dma_ifmaps_c_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_16();
        dma_controller_reg_block.dma_controller_cfg_reg_16.dma_weights_w_step.set(to_reg_data(dma_weights_w_step));
    endfunction

    virtual function void set_dma_controller_cfg_reg_17();
        dma_controller_reg_block.dma_controller_cfg_reg_17.dma_ifmaps_ett.set(to_reg_data(dma_ifmaps_ett));
    endfunction

    virtual function uvm_reg_data_t to_reg_data(sauria_axi4_lite_data_t value);
        uvm_reg_data_t reg_data;
        reg_data = '0;
        reg_data[SAURIA_REG_SIZE-1:0] = value;
        return reg_data;
    endfunction

endclass