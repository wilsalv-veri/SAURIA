class sauria_all_dim_multi_tile_dma_cfg_seq extends sauria_axi4_lite_dma_controller_cfg_base_seq;

    `uvm_object_utils(sauria_all_dim_multi_tile_dma_cfg_seq)

    function new(string name="sauria_all_dim_multi_tile_dma_cfg_seq");
        super.new(name);
        message_id = "SAURIA_ALL_DIM_MULTI_TILE_DMA_CFG_SEQ";
    endfunction

    constraint tensor_dimensions_c {
        dma_tile_x_lim  inside {[MIN_MULTI_TILE_DIM_VAL:MAX_MULTI_TILE_DIM_VAL]}; 
        dma_tile_y_lim  inside {[MIN_MULTI_TILE_DIM_VAL:MAX_MULTI_TILE_DIM_VAL]};  
        dma_tile_c_lim  inside {[MIN_MULTI_TILE_DIM_VAL:MAX_MULTI_TILE_DIM_VAL]};  
        dma_tile_k_lim  inside {[MIN_MULTI_TILE_DIM_VAL:MAX_MULTI_TILE_DIM_VAL]};  
    }
     
endclass
