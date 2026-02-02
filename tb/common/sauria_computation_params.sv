class sauria_computation_params extends uvm_object;

    bit shared;
    bit tensors_start_addr_shared;
    
    sauria_axi4_lite_data_t       start_SRAMA_addr;
    sauria_axi4_lite_data_t       start_SRAMB_addr;
    sauria_axi4_lite_data_t       start_SRAMC_addr;

    //Tile Dimensions
    sauria_axi4_lite_data_t tile_X;
    sauria_axi4_lite_data_t tile_Y;
    sauria_axi4_lite_data_t tile_C;
    sauria_axi4_lite_data_t tile_K;

    //IFMAPS
    //Intra-Tile
    sauria_axi4_lite_data_t ifmaps_X;
    sauria_axi4_lite_data_t ifmaps_Y;
    sauria_axi4_lite_data_t ifmaps_C;

    sauria_axi4_lite_data_t ifmaps_x_step;
    sauria_axi4_lite_data_t ifmaps_y_step;
    sauria_axi4_lite_data_t ifmaps_c_step;

    //Inter-Tile
    sauria_axi4_lite_data_t tile_ifmaps_X;
    sauria_axi4_lite_data_t tile_ifmaps_Y;
    sauria_axi4_lite_data_t tile_ifmaps_x_step;
    sauria_axi4_lite_data_t tile_ifmaps_y_step;
   
    //WEIGHTS
    //Intra-Tile
    sauria_axi4_lite_data_t weights_W;
    sauria_axi4_lite_data_t weights_K;

    sauria_axi4_lite_data_t weights_w_step;
    sauria_axi4_lite_data_t weights_k_step;

    //Inter-Tile
    sauria_axi4_lite_data_t tile_weights_c_step;
    sauria_axi4_lite_data_t tile_weights_K;
    sauria_axi4_lite_data_t tile_weights_k_step;
    
    //PSUMS
    //Intra-Tile
    sauria_axi4_lite_data_t psums_K;    
    sauria_axi4_lite_data_t psums_Y;
    sauria_axi4_lite_data_t psums_X;

    sauria_axi4_lite_data_t tile_psums_x_step;

    sauria_axi4_lite_data_t psums_CX;    
    sauria_axi4_lite_data_t psums_cx_step;
   
    sauria_axi4_lite_data_t psums_CK;     
    sauria_axi4_lite_data_t psums_ck_step;
    
    //Inter-Tile
    sauria_axi4_lite_data_t tile_psums_CY;    
    sauria_axi4_lite_data_t tile_psums_cy_step;
   
    sauria_axi4_lite_data_t tile_psums_CK;    
    sauria_axi4_lite_data_t tile_psums_ck_step;

    sauria_axi4_lite_data_t loop_order;

    bit                     Cw_eq;   
    bit                     Ch_eq;   
    bit                     Ck_eq;   
    bit                     WXfer_op;

    `uvm_object_utils_begin(sauria_computation_params)
        //IFMAPS
        `uvm_field_int(ifmaps_X,             UVM_ALL_ON)
        `uvm_field_int(ifmaps_Y,             UVM_ALL_ON)
        `uvm_field_int(ifmaps_C,             UVM_ALL_ON)

        `uvm_field_int(ifmaps_x_step,        UVM_ALL_ON)
        `uvm_field_int(ifmaps_y_step,        UVM_ALL_ON)
        `uvm_field_int(ifmaps_c_step,        UVM_ALL_ON)

        `uvm_field_int(tile_ifmaps_X,        UVM_ALL_ON)
        `uvm_field_int(tile_ifmaps_Y,        UVM_ALL_ON)
       
        `uvm_field_int(tile_ifmaps_x_step,   UVM_ALL_ON)
        `uvm_field_int(tile_ifmaps_y_step,   UVM_ALL_ON)
       
        //WEIGHTS
        `uvm_field_int(weights_W,           UVM_ALL_ON)
        `uvm_field_int(weights_K,           UVM_ALL_ON)
       
        `uvm_field_int(weights_w_step,      UVM_ALL_ON)
        `uvm_field_int(weights_k_step,      UVM_ALL_ON)
       
        `uvm_field_int(tile_weights_K,      UVM_ALL_ON)
        `uvm_field_int(tile_weights_k_step, UVM_ALL_ON)
       
        //PSUMS
        `uvm_field_int(psums_CX,            UVM_ALL_ON)
        `uvm_field_int(psums_cx_step,       UVM_ALL_ON)
       
        `uvm_field_int(psums_CK,            UVM_ALL_ON)
        `uvm_field_int(psums_ck_step,       UVM_ALL_ON)
       
        `uvm_field_int(tile_psums_CY,       UVM_ALL_ON)
        `uvm_field_int(tile_psums_cy_step,  UVM_ALL_ON)
    
        `uvm_field_int(tile_psums_CK,       UVM_ALL_ON)
        `uvm_field_int(tile_psums_ck_step,  UVM_ALL_ON)

        `uvm_field_int(loop_order,          UVM_ALL_ON)

        `uvm_field_int(Cw_eq,               UVM_ALL_ON)
        `uvm_field_int(Ck_eq,               UVM_ALL_ON)
        `uvm_field_int(Ch_eq,               UVM_ALL_ON)
    
    `uvm_object_utils_end    

    function new(string name="sauria_computation_params");
        super.new(name);
    endfunction

    //IFMAPS
    virtual function sauria_axi4_lite_data_t get_ifmaps_tile_size();
        return tile_ifmaps_x_step; 
    endfunction

    virtual function sauria_axi4_lite_data_t get_ifmaps_size();
        return get_ifmaps_tile_size() * tile_X * tile_Y * tile_C; 
    endfunction

    //WEIGHTS
    virtual function sauria_axi4_lite_data_t get_weights_tile_size();
        return tile_weights_c_step;
    endfunction

    virtual function sauria_axi4_lite_data_t get_weights_size();
        return get_weights_tile_size() * tile_C * tile_K; 
    endfunction

    //PSUMS
    virtual function sauria_axi4_lite_data_t get_psums_tile_size();
        return tile_psums_x_step;
    endfunction

    virtual function sauria_axi4_lite_data_t get_psums_size();
        return get_psums_tile_size() * tile_X * tile_Y * tile_K;
    endfunction

endclass