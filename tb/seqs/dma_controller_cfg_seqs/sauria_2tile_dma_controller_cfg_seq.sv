class sauria_2tile_dma_controller_cfg_seq extends sauria_axi4_lite_dma_controller_cfg_base_seq;

    `uvm_object_utils(sauria_2tile_dma_controller_cfg_seq)

    rand int X;
    rand int Y;
    rand int C;
    rand int K;

    int w_step;

    function new(string name="sauria_2tile_dma_controller_cfg_seq");
        super.new(name);
        message_id = "SAURIA_2TILE_DMA_CONTROLLER_CFG_SEQ";

        turn_off_dependent_constraints();
        
        //Randomize Only Indepedent Constraints
        if (!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_cfg_w_dma_base_seq")
        
        //turn_off_independent_constraints();
        turn_on_dependent_constraints();
        
        //Randomize Only Dependent Constraints
        if (!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_cfg_w_dma_base_seq")
        
    endfunction

   //Independent Constraints
   constraint dimensions_c {
      X == `X;
      Y == `Y;
      C == 4;
      K == 6;
    }

    constraint dma_ifmaps_tile_dimensions_c{
        dma_tile_x_lim == sauria_axi4_lite_data_t'('h1);
        dma_tile_y_lim == sauria_axi4_lite_data_t'('h1);
    }

    constraint dma_weights_tile_dimensions_c {
        dma_tile_c_lim == sauria_axi4_lite_data_t'('h1);
        dma_tile_k_lim == sauria_axi4_lite_data_t'('h1);
    }

    //Dependent Constraints
    constraint dma_ifmaps_dimensions_c {
        dma_ifmaps_y_lim == sauria_axi4_lite_data_t'('h1); 
        dma_ifmaps_c_lim == sauria_axi4_lite_data_t'('h1); 
        dma_ifmaps_ett   == sauria_axi4_lite_data_t'('h8); 
    }

    constraint dma_ifmaps_tile_dimension_steps_c {
        solve dma_tile_ifmaps_x_step before dma_tile_ifmaps_y_step;
        solve dma_tile_ifmaps_y_step before dma_tile_ifmaps_c_step;

        dma_tile_ifmaps_x_step == sauria_axi4_lite_data_t'('h1);
        dma_tile_ifmaps_y_step == sauria_axi4_lite_data_t'('h1);
        dma_tile_ifmaps_c_step == sauria_axi4_lite_data_t'('h1); 
    }

    constraint dma_ifmaps_dimension_steps{
        solve dma_ifmaps_y_step before dma_ifmaps_c_step;
        dma_ifmaps_y_step == sauria_axi4_lite_data_t'(X*df_ctrl_pkg::A_BYTES);
        dma_ifmaps_c_step == sauria_axi4_lite_data_t'(dma_ifmaps_y_step*Y);
    }

    constraint dma_weights_tile_dimension_steps_c {
        dma_tile_weights_k_step == sauria_axi4_lite_data_t'('h1); 
        dma_tile_weights_c_step == sauria_axi4_lite_data_t'('h2); 
    }

    constraint dma_psums_dimension_steps_c {
        dma_psums_y_step == sauria_axi4_lite_data_t'('h1);
        dma_psums_k_step == sauria_axi4_lite_data_t'('h1);
    }
   
    constraint dma_psums_tile_dimension_steps_c {
        dma_tile_psums_x_step == sauria_axi4_lite_data_t'('h1); 
        dma_tile_psums_y_step == sauria_axi4_lite_data_t'('h2); 
        dma_tile_psums_k_step == sauria_axi4_lite_data_t'('h2); 
    }
     
    constraint dma_weights_dimension_steps_c {
        dma_weights_w_step  == sauria_axi4_lite_data_t'('h1);
    }

    virtual function void turn_off_dependent_constraints();
        dma_ifmaps_dimensions_c.constraint_mode(0);
        dma_ifmaps_dimension_steps.constraint_mode(0);
        dma_ifmaps_tile_dimension_steps_c.constraint_mode(0);
        dma_weights_dimension_steps_c.constraint_mode(0);
        dma_weights_tile_dimension_steps_c.constraint_mode(0);
        dma_psums_tile_dimension_steps_c.constraint_mode(0);
    endfunction

    virtual function void turn_off_independent_constraints();
        dimensions_c.constraint_mode(0);
        dma_weights_tile_dimensions_c.constraint_mode(0);
    endfunction

    virtual function void turn_on_dependent_constraints();
        dma_ifmaps_dimensions_c.constraint_mode(1);
        dma_ifmaps_dimension_steps.constraint_mode(1);
        dma_ifmaps_tile_dimension_steps_c.constraint_mode(1);
        dma_weights_dimension_steps_c.constraint_mode(1);
        dma_weights_tile_dimension_steps_c.constraint_mode(1);
        dma_psums_tile_dimension_steps_c.constraint_mode(1);
    endfunction
    

endclass