class sauria_x_dim_multi_tile_dma_cfg_seq extends sauria_axi4_lite_dma_controller_cfg_base_seq;

    `uvm_object_utils(sauria_x_dim_multi_tile_dma_cfg_seq)

    function new(string name="sauria_x_dim_multi_tile_dma_cfg_seq");
        super.new(name);
        message_id = "SAURIA_X_DIM_MULTI_TILE_DMA_CFG_SEQ";
    endfunction

    constraint tensor_dimensions_c {
        dma_tile_x_lim  inside {[MIN_MULTI_TILE_DIM_VAL:MAX_MULTI_TILE_DIM_VAL]}; 
        dma_tile_y_lim  == SINGLE_TILE_DIM_VAL;  
        dma_tile_c_lim  == SINGLE_TILE_DIM_VAL;  
        dma_tile_k_lim  == SINGLE_TILE_DIM_VAL;  
    }
     
endclass