class sauria_computation_params extends uvm_object;

    bit shared;
    bit tensors_start_addr_shared;
    bit main_controller_cfg_shared;
    bit ifmaps_cfg_shared;
    bit weights_cfg_shared;
    bit psums_mgr_cfg_shared;
    
    sauria_axi4_lite_data_t       start_SRAMA_addr;
    sauria_axi4_lite_data_t       start_SRAMB_addr;
    sauria_axi4_lite_data_t       start_SRAMC_addr;

    //Tile Dimensions
    sauria_axi4_lite_data_t tile_X;
    sauria_axi4_lite_data_t tile_Y;
    sauria_axi4_lite_data_t tile_C;
    sauria_axi4_lite_data_t tile_K;

    ifmaps_params_t  df_controller_ifmaps_params;
    ifmaps_params_t  core_ifmaps_params;

    weights_params_t df_controller_weights_params;
    weights_params_t core_weights_params;
    
    psums_params_t   df_controller_psums_params;
    psums_params_t   core_psums_params;

    sauria_axi4_lite_data_t act_reps;
    sauria_axi4_lite_data_t wei_reps;
    sauria_axi4_lite_data_t incntlim;
    sauria_axi4_lite_data_t loop_order;

    sauria_axi4_lite_data_t ifmaps_rows_active;
    sauria_axi4_lite_data_t weights_cols_active;
    sauria_axi4_lite_data_t psums_inactive_cols;
    sauria_axi4_lite_data_t psums_preload_en;

    bit                     Cw_eq;   
    bit                     Ch_eq;   
    bit                     Ck_eq;   
    bit                     WXfer_op;

    `uvm_object_utils_begin(sauria_computation_params) 
       
        `uvm_field_int(incntlim,            UVM_ALL_ON)
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
        return df_controller_ifmaps_params.tensor_params.tile_ifmaps_x_step; 
    endfunction

    virtual function sauria_axi4_lite_data_t get_ifmaps_size();
        return get_ifmaps_tile_size() * tile_X * tile_Y * tile_C; 
    endfunction

    //WEIGHTS
    virtual function sauria_axi4_lite_data_t get_weights_tile_size();
        return df_controller_weights_params.tensor_params.tile_weights_c_step;
    endfunction

    virtual function sauria_axi4_lite_data_t get_weights_size();
        return get_weights_tile_size() * tile_C * tile_K; 
    endfunction

    //PSUMS
    virtual function sauria_axi4_lite_data_t get_psums_tile_size();
        return df_controller_psums_params.tensor_params.tile_psums_cy_step;
    endfunction

    virtual function sauria_axi4_lite_data_t get_psums_size();
        return get_psums_tile_size() * tile_X * tile_Y * tile_K;
    endfunction

endclass