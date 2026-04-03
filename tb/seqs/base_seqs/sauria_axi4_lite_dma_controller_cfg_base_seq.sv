class sauria_axi4_lite_dma_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_dma_controller_cfg_base_seq)

    uvm_status_e                     status;
    sauria_dma_controller_reg_block  dma_controller_reg_block;

    rand int X;
    rand int Y;
    rand int C;
    rand int K;
    rand int W;

    rand sauria_axi4_lite_data_t  dma_tile_x_lim;
    rand sauria_axi4_lite_data_t  dma_tile_y_lim;

    rand sauria_axi4_lite_data_t  dma_tile_c_lim;
    rand sauria_axi4_lite_data_t  dma_tile_k_lim;

    rand sauria_axi4_lite_data_t  dma_tile_psums_x_step;
    rand sauria_axi4_lite_data_t  dma_tile_psums_y_step;
    rand sauria_axi4_lite_data_t  dma_tile_psums_k_step;
    rand sauria_axi4_lite_data_t  dma_tile_ifmaps_x_step;
    rand sauria_axi4_lite_data_t  dma_tile_ifmaps_y_step;
    rand sauria_axi4_lite_data_t  dma_tile_ifmaps_c_step;
    rand sauria_axi4_lite_data_t  dma_tile_weights_k_step;
    rand sauria_axi4_lite_data_t  dma_tile_weights_c_step;
    
    rand sauria_axi4_lite_data_t  dma_ifmaps_y_lim;
    rand sauria_axi4_lite_data_t  dma_ifmaps_c_lim;
    rand sauria_axi4_lite_data_t  dma_psums_y_step;
    rand sauria_axi4_lite_data_t  dma_psums_k_step;
    rand sauria_axi4_lite_data_t  dma_ifmaps_y_step;
    rand sauria_axi4_lite_data_t  dma_ifmaps_c_step;

    rand sauria_axi4_lite_data_t  dma_weights_w_step;
    rand sauria_axi4_lite_data_t  dma_weights_w_lim;
    rand sauria_axi4_lite_data_t  dma_ifmaps_ett;
    
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
        dma_ifmaps_y_lim        == Y - 1; 
        dma_ifmaps_c_lim        == C - 1; 

        dma_ifmaps_y_step       == dma_ifmaps_ett; 
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
        
        dma_weights_w_step      ==  K; 
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

        dma_tile_psums_x_step   == dma_psums_k_step * K; 
        dma_tile_psums_y_step   == dma_tile_psums_x_step * (dma_tile_x_lim + 1);
        dma_tile_psums_k_step   == dma_tile_psums_y_step * (dma_tile_y_lim + 1); 
    }
    
    function new(string name="sauria_axi4_lite_dma_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_DMA_CONTROLLER_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.dma_controller_reg_block = subsystem_reg_block.dma_controller_reg_block;
    endtask

    virtual task body();
        share_computation_params();
        super.body();
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        set_dma_controller_cfg_CRs();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        send_dma_controller_cfg_CRs();
    endtask

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
        computation_params.ifmaps_X            = dma_ifmaps_ett;
        
        computation_params.ifmaps_y_step       = dma_ifmaps_y_step;
        computation_params.ifmaps_Y            = dma_ifmaps_y_lim + 1;
        
        computation_params.ifmaps_c_step       = dma_ifmaps_c_step;
        computation_params.ifmaps_C            = dma_ifmaps_c_lim + 1;

        computation_params.tile_ifmaps_x_step  = dma_tile_ifmaps_x_step;
    endfunction

    virtual function void share_weights_params();

        computation_params.weights_K           = dma_weights_w_step;           
       
        computation_params.weights_w_step      = dma_weights_w_step;
        computation_params.weights_w_lim       = dma_tile_weights_c_step;
        computation_params.weights_W           = dma_tile_weights_c_step / dma_weights_w_step; 
        
        computation_params.tile_weights_c_step = dma_tile_weights_c_step;
    endfunction

    virtual function void share_psums_params();
        
        computation_params.psums_K             = dma_weights_w_step;
        computation_params.psums_Y             = dma_ifmaps_y_lim + 1;
        computation_params.psums_X             = dma_ifmaps_ett;
    
        computation_params.psums_CX            = computation_params.psums_X * computation_params.psums_Y;
        computation_params.tile_psums_x_step   = dma_tile_psums_x_step;
    
    endfunction

    virtual function void set_dma_controller_cfg_CRs();
        set_dma_controller_cfg_reg_0();
        set_dma_controller_cfg_reg_1();
        set_dma_controller_cfg_reg_2();
        set_dma_controller_cfg_reg_3();
        set_dma_controller_cfg_reg_4();
        set_dma_controller_cfg_reg_5();
        set_dma_controller_cfg_reg_6();
        set_dma_controller_cfg_reg_7();
        set_dma_controller_cfg_reg_8();
        set_dma_controller_cfg_reg_9();
        set_dma_controller_cfg_reg_10();
        set_dma_controller_cfg_reg_11();
        set_dma_controller_cfg_reg_12();
        set_dma_controller_cfg_reg_13();
        set_dma_controller_cfg_reg_14();
        set_dma_controller_cfg_reg_15();
        set_dma_controller_cfg_reg_16();
        set_dma_controller_cfg_reg_17(); 
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
        dma_controller_reg_block.dma_controller_cfg_reg_0.dma_tile_x_lim.set(to_reg_data(dma_tile_x_lim));
        dma_controller_reg_block.dma_controller_cfg_reg_0.dma_tile_y_lim.set(to_reg_data(dma_tile_y_lim));
    endfunction

    virtual function void set_dma_controller_cfg_reg_1();
        dma_controller_reg_block.dma_controller_cfg_reg_1.dma_tile_c_lim.set(to_reg_data(dma_tile_c_lim));
        dma_controller_reg_block.dma_controller_cfg_reg_1.dma_tile_k_lim.set(to_reg_data(dma_tile_k_lim));
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