class sauria_ifmaps_eq_array_dma_ctrl_cfg_seq extends sauria_axi4_lite_dma_controller_cfg_base_seq;

    `uvm_object_utils(sauria_ifmaps_eq_array_dma_ctrl_cfg_seq)

    function new(string name="sauria_ifmaps_eq_array_dma_ctrl_cfg_seq");
        super.new(name);
        message_id = "SAURIA_IFMAPS_EQ_ARRAY_DMA_CTRL_CFG_SEQ";
    endfunction

   //Independent Constraints
   constraint tile_dimensions_c {
        X               == `X;
        Y               == `Y;
        W               ==  2;
        C               ==  3;
        K               ==  7;
    }

    constraint tensor_dimensions_c {
        dma_tile_x_lim  == 1; //2
        dma_tile_y_lim  == 1; //2
        dma_tile_c_lim  == 1; //3
        dma_tile_k_lim  == 1; //4
    }
     
endclass