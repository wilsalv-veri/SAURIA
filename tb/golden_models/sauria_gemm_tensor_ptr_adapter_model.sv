class sauria_gemm_tensor_ptr_adapter_model extends sauria_base_model;

    `uvm_object_utils(sauria_gemm_tensor_ptr_adapter_model)

    gemm_tensor_model gemm_schedule_model;

    function new(string name="sauria_gemm_tensor_ptr_adapter_model");
        super.new(name);
        message_id = "SAURIA_GEMM_TENSOR_PTR_ADAPTER_MODEL";
        gemm_schedule_model = gemm_tensor_model::type_id::create("gemm_tensor_model");
    endfunction

    virtual function void set_computation_params(sauria_computation_params computation_params);
        super.set_computation_params(computation_params);
        gemm_schedule_model.set_computation_params(computation_params);
    endfunction

    virtual function void reset_model();
        gemm_schedule_model.reset_model();
    endfunction

    virtual function dma_req_addr_check_result_t observe_rd_addr(sauria_axi4_rd_addr_seq_item dma_rd_addr);
        dma_req_addr_check_result_t result = init_dma_req_addr_result();

        ensure_configured();

        result.debug_map_valid = 1'b1;
        result.debug_map       = get_cached_event_addr_map(1'b0);
        result.exp_addr       = get_next_exp_rd_address();
        result.addr_mismatch  = (result.exp_addr != dma_rd_addr.araddr);
        result.burst_mismatch = (dma_rd_addr.arburst != INCR);
        result.debug_map.row_addr = result.exp_addr;

        return result;
    endfunction

    virtual function dma_req_addr_check_result_t observe_wr_addr(sauria_axi4_wr_addr_seq_item dma_wr_addr);
        dma_req_addr_check_result_t result = init_dma_req_addr_result();

        ensure_configured();

        result.debug_map_valid = 1'b1;
        result.debug_map       = get_cached_event_addr_map(1'b1);
        result.exp_addr       = get_next_exp_wr_address();
        result.addr_mismatch  = (result.exp_addr != dma_wr_addr.awaddr);
        result.burst_mismatch = (dma_wr_addr.awburst != INCR);
        result.psums_tile_idx = get_current_psums_tile_idx();
        result.debug_map.row_addr = result.exp_addr;
        result.debug_map.reported_psums_tile_idx = result.psums_tile_idx;

        return result;
    endfunction

    virtual function sauria_axi4_addr_t get_next_exp_rd_address();
        ensure_configured();
        gemm_schedule_model.advance_next_read_event();

        if (!gemm_schedule_model.get_cached_event_valid(1'b0))
            return sauria_axi4_addr_t'('hdeadbeef);

        return get_cached_event_addr_map(1'b0).row_addr & DATA_AXI_ADDR_MASK;
    endfunction

    virtual function sauria_axi4_addr_t get_next_exp_wr_address();
        ensure_configured();
        gemm_schedule_model.advance_next_write_event();

        if (!gemm_schedule_model.get_cached_event_valid(1'b1))
            return sauria_axi4_addr_t'('hdeadbeef);

        return get_cached_event_addr_map(1'b1).row_addr & DATA_AXI_ADDR_MASK;
    endfunction

    local function sauria_axi4_addr_t get_tensor_base_addr(sauria_tensor_type_t tensor);
        case (tensor)
            IFMAPS:  return sauria_axi4_addr_t'(start_SRAMA_addr);
            WEIGHTS: return sauria_axi4_addr_t'(start_SRAMB_addr);
            PSUMS:   return sauria_axi4_addr_t'(start_SRAMC_addr);
            default: return sauria_axi4_addr_t'(0);
        endcase
    endfunction

    local function gemm_sauria_addr_map_t get_cached_event_addr_map(bit write_event);
        gemm_sauria_addr_map_t result;
        sauria_axi4_addr_t total_tensor_offset;

        result.valid                     = gemm_schedule_model.get_cached_event_valid(write_event);
        result.tensor                    = gemm_schedule_model.get_cached_event_tensor(write_event);
        result.access_dir                = write_event ? GEMM_ACCESS_WRITE : GEMM_ACCESS_READ;
        result.m_tile_idx                = gemm_schedule_model.get_cached_event_m_tile_idx(write_event);
        result.k_tile_idx                = gemm_schedule_model.get_cached_event_k_tile_idx(write_event);
        result.n_tile_idx                = gemm_schedule_model.get_cached_event_n_tile_idx(write_event);
        result.m_block_idx               = gemm_schedule_model.get_cached_event_m_block_idx(write_event);
        result.k_block_idx               = gemm_schedule_model.get_cached_event_k_block_idx(write_event);
        result.n_block_idx               = gemm_schedule_model.get_cached_event_n_block_idx(write_event);
        result.sauria_tile_idx           = get_cached_sauria_tile_idx(write_event, result.tensor);
        result.reported_psums_tile_idx   = write_event ? get_current_psums_tile_idx() : -1;
        result.intra_tile_offset         = get_cached_event_intra_tile_offset(write_event);
        result.tile_offset               = get_cached_event_tile_offset(write_event);
        total_tensor_offset              = result.intra_tile_offset + result.tile_offset;
        result.elem_byte_offset          = sauria_axi4_addr_t'(total_tensor_offset * get_tensor_element_bytes(result.tensor));
        result.final_c_write             = gemm_schedule_model.get_cached_event_final_c_write(write_event);
        result.row_addr                  = get_tensor_base_addr(result.tensor) + result.elem_byte_offset;

        return result;
    endfunction

    local function sauria_axi4_addr_t get_cached_event_intra_tile_offset(bit write_event);
        case (gemm_schedule_model.get_cached_event_tensor(write_event))
            IFMAPS:
                return sauria_axi4_addr_t'((gemm_schedule_model.get_cached_event_k_block_idx(write_event) * ifmap_Y * ifmap_X) +
                                           (gemm_schedule_model.get_cached_event_m_block_idx(write_event) * ifmap_X));
            WEIGHTS:
                return sauria_axi4_addr_t'(gemm_schedule_model.get_cached_event_k_block_idx(write_event) * weights_K);
            PSUMS:
                return sauria_axi4_addr_t'((gemm_schedule_model.get_cached_event_n_block_idx(write_event) * seq_psums_Y * psums_X) +
                                           (gemm_schedule_model.get_cached_event_m_block_idx(write_event) * psums_X));
            default:
                return sauria_axi4_addr_t'(0);
        endcase
    endfunction

    local function sauria_axi4_addr_t get_cached_event_tile_offset(bit write_event);
        case (gemm_schedule_model.get_cached_event_tensor(write_event))
            IFMAPS:
                return sauria_axi4_addr_t'(ifmaps_tile_size * get_cached_ifmaps_tile_idx(write_event));
            WEIGHTS:
                return sauria_axi4_addr_t'(weights_tile_size * get_cached_weights_tile_idx(write_event));
            PSUMS:
                return sauria_axi4_addr_t'(psums_tile_size * get_cached_psums_tile_idx(write_event));
            default:
                return sauria_axi4_addr_t'(0);
        endcase
    endfunction

    local function int get_cached_sauria_tile_idx(bit write_event, sauria_tensor_type_t tensor);
        case (tensor)
            IFMAPS:  return get_cached_ifmaps_tile_idx(write_event);
            WEIGHTS: return get_cached_weights_tile_idx(write_event);
            PSUMS:   return get_cached_psums_tile_idx(write_event);
            default: return 0;
        endcase
    endfunction

    local function int get_cached_ifmaps_tile_idx(bit write_event);
        return (gemm_schedule_model.get_cached_event_k_tile_idx(write_event) * get_m_tile_count()) +
               gemm_schedule_model.get_cached_event_m_tile_idx(write_event);
    endfunction

    local function int get_cached_weights_tile_idx(bit write_event);
        return (gemm_schedule_model.get_cached_event_n_tile_idx(write_event) * tile_C) +
               gemm_schedule_model.get_cached_event_k_tile_idx(write_event);
    endfunction

    local function int get_cached_psums_tile_idx(bit write_event);
        return (gemm_schedule_model.get_cached_event_n_tile_idx(write_event) * get_m_tile_count()) +
               gemm_schedule_model.get_cached_event_m_tile_idx(write_event);
    endfunction

    local function int get_current_psums_tile_idx();
        return (gemm_schedule_model.get_current_n_tile_idx() * get_m_tile_count()) +
               gemm_schedule_model.get_current_m_tile_idx();
    endfunction

    local function int get_tensor_element_bytes(sauria_tensor_type_t tensor);
        case (tensor)
            IFMAPS:  return df_ctrl_pkg::A_BYTES;
            WEIGHTS: return df_ctrl_pkg::B_BYTES;
            PSUMS:   return df_ctrl_pkg::C_BYTES;
            default: return 0;
        endcase
    endfunction

    local function sauria_axi4_lite_data_t get_m_tile_count();
        return sauria_axi4_lite_data_t'(tile_X * tile_Y);
    endfunction

endclass