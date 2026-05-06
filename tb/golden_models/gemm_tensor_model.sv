class gemm_tensor_model extends sauria_base_model;

    `uvm_object_utils(gemm_tensor_model)

    sauria_axi4_lite_data_t a_m_counter;
    sauria_axi4_lite_data_t a_k_counter;
    sauria_axi4_lite_data_t b_k_counter;
    sauria_axi4_lite_data_t c_m_counter;
    sauria_axi4_lite_data_t c_n_counter;

    sauria_axi4_lite_data_t tile_m_counter;
    sauria_axi4_lite_data_t tile_k_counter;
    sauria_axi4_lite_data_t tile_n_counter;

    sauria_axi4_lite_data_t prev_c_tile_m_counter;
    sauria_axi4_lite_data_t prev_c_tile_n_counter;

    bit                     rd_operands_done;
    bit                     a_done;
    bit                     b_done;
    bit                     c_done;

    bit                     update_prev_c_tile = 1'b1;
    bit                     c_tile_wr_n_minus_1;

    gemm_tensor_access_event_t last_read_event;
    gemm_tensor_access_event_t last_write_event;

    function new(string name="gemm_tensor_model");
        super.new(name);
        message_id = "GEMM_TENSOR_MODEL";
    endfunction

    virtual function gemm_problem_shape_t get_problem_shape();
        gemm_problem_shape_t shape = '{default:'0};

        ensure_configured();

        shape.tile_m_count = sauria_axi4_lite_data_t'(tile_X * tile_Y);
        shape.tile_k_count = tile_C;
        shape.tile_n_count = tile_K;

        shape.a_m_per_tile = sauria_axi4_lite_data_t'(ifmap_X * ifmap_Y);
        shape.a_k_per_tile = ifmap_C;
        shape.b_k_per_tile = weights_W;
        shape.b_n_per_tile = weights_K;
        shape.c_m_per_tile = sauria_axi4_lite_data_t'(psums_X * psums_Y);
        shape.c_n_per_tile = psums_K;

        shape.total_m = sauria_axi4_lite_data_t'(shape.c_m_per_tile * shape.tile_m_count);
        shape.total_k = sauria_axi4_lite_data_t'(shape.a_k_per_tile * shape.tile_k_count);
        shape.total_n = sauria_axi4_lite_data_t'(shape.c_n_per_tile * shape.tile_n_count);

        return shape;
    endfunction

    virtual function void reset_model();
        a_m_counter          = 0;
        a_k_counter          = 0;
        b_k_counter          = 0;
        c_m_counter          = 0;
        c_n_counter          = 0;
        tile_m_counter       = 0;
        tile_k_counter       = 0;
        tile_n_counter       = 0;
        prev_c_tile_m_counter = 0;
        prev_c_tile_n_counter = 0;
        rd_operands_done     = 1'b0;
        a_done               = 1'b0;
        b_done               = 1'b0;
        c_done               = 1'b0;
        update_prev_c_tile   = 1'b1;
        c_tile_wr_n_minus_1  = 1'b0;
        last_read_event      = get_invalid_event();
        last_write_event     = get_invalid_event();
    endfunction

    local function gemm_tensor_access_event_t get_invalid_event();
        get_invalid_event.valid               = 1'b0;
        get_invalid_event.operand             = GEMM_OPERAND_A;
        get_invalid_event.access_dir          = GEMM_ACCESS_READ;
        get_invalid_event.m_tile_idx          = 0;
        get_invalid_event.k_tile_idx          = 0;
        get_invalid_event.n_tile_idx          = 0;
        get_invalid_event.m_block_idx         = 0;
        get_invalid_event.k_block_idx         = 0;
        get_invalid_event.n_block_idx         = 0;
        get_invalid_event.contiguous_span     = 0;
        get_invalid_event.requires_existing_c = 1'b0;
        get_invalid_event.final_c_write       = 1'b0;
    endfunction

    virtual function void advance_next_read_event();
        last_read_event = get_next_read_event();
    endfunction

    virtual function void advance_next_write_event();
        last_write_event = get_next_write_event();
    endfunction

    virtual function bit get_cached_event_valid(bit write_event);
        return write_event ? last_write_event.valid : last_read_event.valid;
    endfunction

    virtual function sauria_tensor_type_t get_cached_event_tensor(bit write_event);
        gemm_tensor_operand_t operand;

        operand = write_event ? last_write_event.operand : last_read_event.operand;

        case (operand)
            GEMM_OPERAND_A: return IFMAPS;
            GEMM_OPERAND_B: return WEIGHTS;
            GEMM_OPERAND_C: return PSUMS;
            default:        return IFMAPS;
        endcase
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_m_tile_idx(bit write_event);
        return write_event ? last_write_event.m_tile_idx : last_read_event.m_tile_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_k_tile_idx(bit write_event);
        return write_event ? last_write_event.k_tile_idx : last_read_event.k_tile_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_n_tile_idx(bit write_event);
        return write_event ? last_write_event.n_tile_idx : last_read_event.n_tile_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_m_block_idx(bit write_event);
        return write_event ? last_write_event.m_block_idx : last_read_event.m_block_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_k_block_idx(bit write_event);
        return write_event ? last_write_event.k_block_idx : last_read_event.k_block_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_n_block_idx(bit write_event);
        return write_event ? last_write_event.n_block_idx : last_read_event.n_block_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_cached_event_span(bit write_event);
        return write_event ? last_write_event.contiguous_span : last_read_event.contiguous_span;
    endfunction

    virtual function bit get_cached_event_final_c_write(bit write_event);
        return write_event ? last_write_event.final_c_write : 1'b0;
    endfunction

    virtual function sauria_axi4_lite_data_t get_current_m_tile_idx();
        return tile_m_counter;
    endfunction

    virtual function sauria_axi4_lite_data_t get_current_k_tile_idx();
        return tile_k_counter;
    endfunction

    virtual function sauria_axi4_lite_data_t get_current_n_tile_idx();
        return tile_n_counter;
    endfunction

    virtual function gemm_tensor_access_event_t get_next_read_event();
        get_next_read_event = get_invalid_event();

        ensure_configured();

        if (rd_operands_done)
            return get_next_read_event;

        if (is_curr_tile_iteration_done()) begin
            clear_done_signals();

            if (update_prev_c_tile)
                capture_prev_c_tile_indices();

            if (loop_order == 0)
                m_fastest_update_tile_counters();
            else if (loop_order == 1)
                k_fastest_update_tile_counters();
            else if (loop_order == 2)
                n_fastest_update_tile_counters();

            `sauria_info(message_id,
                         $sformatf("GEMM tile counters M:%0d K:%0d N:%0d",
                                   tile_m_counter,
                                   tile_k_counter,
                                   tile_n_counter))
        end

        get_next_read_event = get_next_tile_read_event();
        rd_operands_done = is_done_getting_tile_accesses();

        if (rd_operands_done)
            clear_done_signals();

        return get_next_read_event;
    endfunction

    virtual function gemm_tensor_access_event_t get_next_write_event();
        get_next_write_event = get_invalid_event();

        ensure_configured();
        update_prev_c_tile = 1'b1;

        if (c_tile_wr_n_minus_1 && c_done) begin
            clear_done_signals();
            capture_prev_c_tile_indices();
        end

        if (rd_operands_done)
            c_tile_wr_n_minus_1 = 1'b1;

        get_next_write_event = build_c_write_event();
        update_c_counters();

        return get_next_write_event;
    endfunction

    virtual function gemm_tensor_access_event_t get_next_tile_read_event();
        case (select_operand())
            GEMM_OPERAND_A: return build_a_read_event();
            GEMM_OPERAND_B: return build_b_read_event();
            GEMM_OPERAND_C: return build_c_read_event();
            default:        return get_invalid_event();
        endcase
    endfunction

    virtual function gemm_tensor_operand_t select_operand();
        if (!a_done && !b_done && !c_done) begin
            if (get_operand_a())
                return GEMM_OPERAND_A;

            a_done = 1'b1;
            return GEMM_OPERAND_B;
        end
        else if (a_done && get_operand_b() && !b_done)
            return GEMM_OPERAND_B;
        else if (a_done && (b_done || !get_operand_b()) && get_operand_c() && !c_done)
            return GEMM_OPERAND_C;

        return GEMM_OPERAND_C;
    endfunction

    virtual function bit get_operand_a();
        if (is_first_tile())
            return 1'b1;
        else if (loop_order == 0)
            return 1'b1;
        else if (loop_order == 1)
            return 1'b1;
        else if (loop_order == 2)
            return (tile_n_counter == 0);
    endfunction

    virtual function bit get_operand_b();
        if (is_first_tile())
            return 1'b1;
        else if (loop_order == 0)
            return (tile_m_counter == 0);
        else if (loop_order == 1)
            return ((tile_C > 1) || (tile_K > 1));
        else if (loop_order == 2)
            return ((tile_C > 1) || (tile_K > 1));
    endfunction

    virtual function bit get_operand_c();
        if (is_first_tile())
            return 1'b1;
        else if (loop_order == 0)
            return 1'b1;
        else if (loop_order == 1)
            return (tile_k_counter == 0);
        else if (loop_order == 2)
            return 1'b1;
    endfunction

    virtual function bit is_curr_tile_iteration_done();
        return ((tile_k_counter != 0) && (loop_order == 2'h1)) ? b_done : c_done;
    endfunction

    virtual function bit is_done_getting_tile_accesses();
        return is_last_tile() && is_curr_tile_iteration_done();
    endfunction

    virtual function bit is_last_tile();
        bit done_m = (tile_m_counter == (get_m_tile_count() - 1));
        bit done_k = (tile_k_counter == (tile_C - 1));
        bit done_n = (tile_n_counter == (tile_K - 1));
        return done_m && done_k && done_n;
    endfunction

    virtual function bit is_first_tile();
        return (tile_m_counter == 0) && (tile_k_counter == 0) && (tile_n_counter == 0);
    endfunction

    virtual function void clear_done_signals();
        a_done = 1'b0;
        b_done = 1'b0;
        c_done = 1'b0;
    endfunction

    virtual function void capture_prev_c_tile_indices();
        update_prev_c_tile     = 1'b0;
        prev_c_tile_m_counter  = tile_m_counter;
        prev_c_tile_n_counter  = tile_n_counter;
    endfunction

    virtual function sauria_axi4_lite_data_t get_m_tile_count();
        return sauria_axi4_lite_data_t'(tile_X * tile_Y);
    endfunction

    virtual function void m_fastest_update_tile_counters();
        if ((tile_k_counter == (tile_C - 1)) && (tile_m_counter == (get_m_tile_count() - 1))) begin
            tile_m_counter = 0;
            tile_k_counter = 0;
            tile_n_counter += 1;
        end
        else if (tile_m_counter == (get_m_tile_count() - 1)) begin
            tile_m_counter = 0;
            tile_k_counter += 1;
        end
        else if (tile_m_counter < get_m_tile_count()) begin
            tile_m_counter += 1;
        end
    endfunction

    virtual function void k_fastest_update_tile_counters();
        if ((tile_k_counter == (tile_C - 1)) && (tile_n_counter == (tile_K - 1))) begin
            tile_k_counter = 0;
            tile_n_counter = 0;
            tile_m_counter += 1;
        end
        else if (tile_k_counter == (tile_C - 1)) begin
            tile_k_counter = 0;
            tile_n_counter += 1;
        end
        else if (tile_k_counter < tile_C) begin
            tile_k_counter += 1;
        end
    endfunction

    virtual function void n_fastest_update_tile_counters();
        if ((tile_n_counter == (tile_K - 1)) && (tile_k_counter == (tile_C - 1))) begin
            tile_n_counter = 0;
            tile_k_counter = 0;
            tile_m_counter += 1;
        end
        else if (tile_n_counter == (tile_K - 1)) begin
            tile_n_counter = 0;
            tile_k_counter += 1;
        end
        else if (tile_n_counter < tile_K) begin
            tile_n_counter += 1;
        end
    endfunction

    virtual function gemm_tensor_access_event_t build_a_read_event();
        build_a_read_event = get_invalid_event();

        build_a_read_event.valid           = 1'b1;
        build_a_read_event.operand         = GEMM_OPERAND_A;
        build_a_read_event.access_dir      = GEMM_ACCESS_READ;
        build_a_read_event.m_tile_idx      = tile_m_counter;
        build_a_read_event.k_tile_idx      = tile_k_counter;
        build_a_read_event.n_tile_idx      = tile_n_counter;
        build_a_read_event.m_block_idx     = a_m_counter;
        build_a_read_event.k_block_idx     = a_k_counter;
        build_a_read_event.contiguous_span = ifmap_X;

        update_a_counters();
    endfunction

    virtual function gemm_tensor_access_event_t build_b_read_event();
        build_b_read_event = get_invalid_event();

        build_b_read_event.valid           = 1'b1;
        build_b_read_event.operand         = GEMM_OPERAND_B;
        build_b_read_event.access_dir      = GEMM_ACCESS_READ;
        build_b_read_event.m_tile_idx      = tile_m_counter;
        build_b_read_event.k_tile_idx      = tile_k_counter;
        build_b_read_event.n_tile_idx      = tile_n_counter;
        build_b_read_event.k_block_idx     = b_k_counter;
        build_b_read_event.contiguous_span = weights_K;

        update_b_counters();
    endfunction

    virtual function gemm_tensor_access_event_t build_c_read_event();
        build_c_read_event = get_invalid_event();

        build_c_read_event.valid               = 1'b1;
        build_c_read_event.operand             = GEMM_OPERAND_C;
        build_c_read_event.access_dir          = GEMM_ACCESS_READ;
        build_c_read_event.m_tile_idx          = tile_m_counter;
        build_c_read_event.k_tile_idx          = tile_k_counter;
        build_c_read_event.n_tile_idx          = tile_n_counter;
        build_c_read_event.m_block_idx         = c_m_counter;
        build_c_read_event.n_block_idx         = c_n_counter;
        build_c_read_event.contiguous_span     = psums_X;
        build_c_read_event.requires_existing_c = 1'b1;

        update_c_counters();
    endfunction

    virtual function gemm_tensor_access_event_t build_c_write_event();
        build_c_write_event = get_invalid_event();

        build_c_write_event.valid           = 1'b1;
        build_c_write_event.operand         = GEMM_OPERAND_C;
        build_c_write_event.access_dir      = GEMM_ACCESS_WRITE;
        build_c_write_event.m_tile_idx      = prev_c_tile_m_counter;
        build_c_write_event.n_tile_idx      = prev_c_tile_n_counter;
        build_c_write_event.m_block_idx     = c_m_counter;
        build_c_write_event.n_block_idx     = c_n_counter;
        build_c_write_event.contiguous_span = psums_X;
        build_c_write_event.final_c_write   = c_tile_wr_n_minus_1;
    endfunction

    virtual function void update_a_counters();
        if ((a_m_counter == (ifmap_Y - 1)) && (a_k_counter == (ifmap_C - 1))) begin
            a_m_counter = 0;
            a_k_counter = 0;
            a_done      = 1'b1;
        end
        else if (a_m_counter == (ifmap_Y - 1)) begin
            a_m_counter = 0;
            a_k_counter += 1;
        end
        else if (a_m_counter < ifmap_Y) begin
            a_m_counter += 1;
        end
    endfunction

    virtual function void update_b_counters();
        if (b_k_counter == (weights_W - 1)) begin
            b_k_counter = 0;
            b_done      = 1'b1;
        end
        else if (b_k_counter < weights_W) begin
            b_k_counter += 1;
        end
    endfunction

    virtual function void update_c_counters();
        if ((c_m_counter == (psums_Y - 1)) && (c_n_counter == (psums_K - 1))) begin
            c_m_counter = 0;
            c_n_counter = 0;
            c_done      = 1'b1;
        end
        else if (c_m_counter == (psums_Y - 1)) begin
            c_m_counter = 0;
            c_n_counter += 1;
        end
        else if (c_m_counter < psums_Y) begin
            c_m_counter += 1;
        end
    endfunction

endclass