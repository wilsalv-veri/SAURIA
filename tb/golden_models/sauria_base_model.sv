class sauria_base_model extends uvm_object;

    `uvm_object_utils(sauria_base_model)

    string message_id = "SAURIA_BASE_MODEL";

    sauria_computation_params computation_params;
    bit                      is_configured;

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
    sauria_axi4_lite_data_t cr_loop_order;
    sauria_axi4_lite_data_t tile_dim_loop_order;
    
    bit                     Cw_eq;   
    bit                     Ch_eq;   
    bit                     Ck_eq;   
    bit                     WXfer_op;
    bit                     single_tile;

    function new(string name="sauria_base_model");
        super.new(name);
    endfunction

    protected function gemm_sauria_addr_map_t init_debug_map();
        gemm_sauria_addr_map_t result;

        result.valid                   = 1'b0;
        result.tensor                  = IFMAPS;
        result.access_dir              = GEMM_ACCESS_READ;
        result.m_tile_idx              = '0;
        result.k_tile_idx              = '0;
        result.n_tile_idx              = '0;
        result.m_block_idx             = '0;
        result.k_block_idx             = '0;
        result.n_block_idx             = '0;
        result.sauria_tile_idx         = 0;
        result.reported_psums_tile_idx = -1;
        result.intra_tile_offset       = '0;
        result.tile_offset             = '0;
        result.elem_byte_offset        = '0;
        result.row_addr                = '0;
        result.final_c_write           = 1'b0;

        return result;
    endfunction

    protected function dma_req_addr_check_result_t init_dma_req_addr_result();
        dma_req_addr_check_result_t result;

        result.addr_mismatch   = 1'b0;
        result.exp_addr        = '0;
        result.burst_mismatch  = 1'b0;
        result.psums_tile_idx  = 0;
        result.debug_map_valid = 1'b0;
        result.debug_map       = init_debug_map();

        return result;
    endfunction

    virtual function void set_computation_params(sauria_computation_params computation_params);
        this.computation_params = computation_params;
        is_configured           = 1'b0;
    endfunction

    virtual function void configure_model(sauria_computation_params computation_params);
        set_tensor_modifiers(computation_params);
        set_tensor_dimensions(computation_params);
        set_tensor_start_addr(computation_params);
        set_tile_sizes(computation_params);
        set_loop_order(computation_params);
        is_configured = 1'b1;
    endfunction

    virtual function void ensure_configured();
        if (is_configured)
            return;

        if (computation_params == null)
            `sauria_fatal(message_id, "Computation params handle was not provided")

        if (!(computation_params.tensors_start_addr_shared && computation_params.shared))
            `sauria_fatal(message_id, "DMA model used before computation params were shared")

        configure_model(computation_params);
    endfunction

    virtual function void set_tensor_dimensions(sauria_computation_params computation_params);
        `sauria_info(message_id, "Getting Computation Params")
        ifmap_X     = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_X;
        ifmap_Y     = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_Y; 
        ifmap_C     = computation_params.df_controller_ifmaps_params.tile_params.ifmaps_C; 

        weights_W   = Ck_eq ? 1 : computation_params.df_controller_weights_params.tile_params.weights_W;
        weights_K   = computation_params.df_controller_weights_params.tile_params.weights_K;

        psums_X     = computation_params.df_controller_psums_params.tile_params.psums_X;
        psums_Y     = Cw_eq ? 1 : computation_params.df_controller_psums_params.tile_params.psums_Y; 
        psums_K     = Cw_eq & Ch_eq ? 1 : computation_params.df_controller_psums_params.tile_params.psums_K;
        seq_psums_Y = computation_params.df_controller_psums_params.tile_params.psums_Y;
        seq_psums_K = computation_params.df_controller_psums_params.tile_params.psums_K;
        
        tile_X      = computation_params.tile_X;
        tile_Y      = computation_params.tile_Y;
        tile_C      = computation_params.tile_C;
        tile_K      = computation_params.tile_K;

        tile_dim_loop_order = get_tile_dim_loop_order();
    
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
        cr_loop_order = computation_params.loop_order;
        loop_order = (tile_dim_loop_order == sauria_axi4_lite_data_t'(3)) ? cr_loop_order : tile_dim_loop_order;
        
        show_tensor_dimensions();
        `sauria_info(message_id, $sformatf("Loop Order: %d Tile_Dim_Loop_Order: %0d Is Single Dim: %0d", 
        loop_order, tile_dim_loop_order, is_single_dim_multi_tile()))
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

    virtual function sauria_axi4_lite_data_t get_tile_dim_loop_order();
        if (is_single_dim_multi_tile())begin

            if (x_only_multi_dim || y_only_multi_dim) return computation_params.loop_order;
            else if (c_only_multi_dim) return 1;
            else if (k_only_multi_dim) return 2;
        end
        else return 3; //Non-Valid Value
    endfunction

    virtual function bit is_single_dim_multi_tile();
        return x_only_multi_dim() || y_only_multi_dim() || c_only_multi_dim() || k_only_multi_dim();
    endfunction

    virtual function bit x_only_multi_dim();
        return (tile_X > 1) && (tile_Y == 1) && (tile_C == 1) && (tile_K == 1);
    endfunction

    virtual function bit y_only_multi_dim();
        return (tile_X == 1) && (tile_Y > 1) && (tile_C == 1) && (tile_K == 1);
    endfunction

    virtual function bit c_only_multi_dim();
        return (tile_X == 1) && (tile_Y == 1) && (tile_C > 1) && (tile_K == 1);
    endfunction

    virtual function bit k_only_multi_dim();
        return (tile_X == 1) && (tile_Y == 1) && (tile_C == 1) && (tile_K > 1);
    endfunction

endclass