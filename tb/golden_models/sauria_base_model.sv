class sauria_base_model extends uvm_object;

    `uvm_object_utils(sauria_base_model)

    string message_id = "SAURIA_BASE_MODEL";

    sauria_axi4_lite_data_t ifmap_X;
    sauria_axi4_lite_data_t ifmap_Y;
    sauria_axi4_lite_data_t ifmap_C;
                                
    sauria_axi4_lite_data_t weights_W;
    sauria_axi4_lite_data_t weights_K;

    sauria_axi4_lite_data_t psums_X;
    sauria_axi4_lite_data_t psums_Y;
    sauria_axi4_lite_data_t psums_K;
    sauria_axi4_lite_data_t seq_psums_Y;
    sauria_axi4_lite_data_t seq_psums_K;
    
    sauria_axi4_lite_data_t tile_X;
    sauria_axi4_lite_data_t tile_Y;
    sauria_axi4_lite_data_t tile_C;
    sauria_axi4_lite_data_t tile_K;

    sauria_axi4_lite_data_t start_SRAMA_addr;
    sauria_axi4_lite_data_t start_SRAMB_addr;
    sauria_axi4_lite_data_t start_SRAMC_addr;

    sauria_axi4_lite_data_t ifmaps_tile_size;
    sauria_axi4_lite_data_t weights_tile_size;
    sauria_axi4_lite_data_t psums_tile_size;

    sauria_axi4_lite_data_t loop_order;

    bit                     Cw_eq;   
    bit                     Ch_eq;   
    bit                     Ck_eq;   
    bit                     WXfer_op;
    bit                     single_tile;

    function new(string name="sauria_base_model");
        super.new(name);
    endfunction

    virtual function void configure_model(sauria_computation_params computation_params);
        set_tensor_modifiers(computation_params);
        set_tensor_dimensions(computation_params);
        set_tensor_start_addr(computation_params);
        set_tile_sizes(computation_params);
        set_loop_order(computation_params);
    endfunction

    virtual function void set_tensor_dimensions(sauria_computation_params computation_params);
        `sauria_info(message_id, "Getting Computation Params")
        ifmap_X     = computation_params.ifmaps_X;
        ifmap_Y     = computation_params.ifmaps_Y + 1; //From limit
        ifmap_C     = computation_params.ifmaps_C + 1; //From limit

        weights_W   = Ck_eq ? 1 : computation_params.weights_W;
        weights_K   = computation_params.weights_K;

        psums_X     = computation_params.psums_X;
        psums_Y     = Cw_eq ? 1 : computation_params.psums_Y + 1; //From limit
        psums_K     = Cw_eq & Ch_eq ? 1 : computation_params.psums_K;
        seq_psums_Y = computation_params.psums_Y + 1;
        seq_psums_K = computation_params.psums_K + 1;
        
        tile_X      = computation_params.tile_X;
        tile_Y      = computation_params.tile_Y;
        tile_C      = computation_params.tile_C;
        tile_K      = computation_params.tile_K;

        single_tile = is_single_tile();
    endfunction

    virtual function void set_tensor_start_addr(sauria_computation_params computation_params);
        start_SRAMA_addr = computation_params.start_SRAMA_addr;
        start_SRAMB_addr = computation_params.start_SRAMB_addr;
        start_SRAMC_addr = computation_params.start_SRAMC_addr;
    endfunction

    virtual function void set_tile_sizes(sauria_computation_params computation_params);
        ifmaps_tile_size  = computation_params.get_ifmaps_tile_size();
        weights_tile_size = computation_params.get_weights_tile_size();
        psums_tile_size   = computation_params.get_psums_tile_size(); 
    endfunction

    virtual function void set_loop_order(sauria_computation_params computation_params);
        loop_order = computation_params.loop_order;
    endfunction

    virtual function void set_tensor_modifiers(sauria_computation_params computation_params);
        Cw_eq    = computation_params.Cw_eq;
        Ch_eq    = computation_params.Ch_eq;
        Ck_eq    = computation_params.Ck_eq;
        WXfer_op = computation_params.WXfer_op;
    endfunction
    
    virtual function void show_tensor_dimensions();
        `sauria_info(message_id, $sformatf("Tile Dimensions K: %0d C: %0d Y: %0d X: %0d", tile_K, tile_C, tile_Y, tile_X))
        `sauria_info(message_id, $sformatf("IFMAPS Dimensions C: %0d Y: %0d X: %0d", ifmap_C, ifmap_Y, ifmap_X))
        `sauria_info(message_id, $sformatf("WEIGHTS Dimensions W: %0d K: %0d", weights_W, weights_K))
        `sauria_info(message_id, $sformatf("PSUMS Dimensions K: %0d Y: %0d X: %0d", psums_K, psums_Y, psums_X))
    endfunction

    virtual function bit is_single_tile();
        return (tile_K == 0) && (tile_C == 0) && (tile_Y == 0) && (tile_X == 0);
    endfunction

endclass