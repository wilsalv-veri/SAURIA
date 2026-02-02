class sauria_tensor_ptr_model extends sauria_base_model;

    `uvm_object_utils(sauria_tensor_ptr_model)

    sauria_axi4_lite_data_t ifmaps_y_counter;
    sauria_axi4_lite_data_t ifmaps_c_counter;
    sauria_axi4_lite_data_t weights_w_counter;
    sauria_axi4_lite_data_t psums_y_counter;
    sauria_axi4_lite_data_t psums_k_counter;
   
    sauria_axi4_lite_data_t tile_X_counter;
    sauria_axi4_lite_data_t tile_Y_counter;
    sauria_axi4_lite_data_t tile_C_counter;
    sauria_axi4_lite_data_t tile_K_counter;

    sauria_axi4_lite_data_t ifmap_addr_offset;
    sauria_axi4_lite_data_t weights_addr_offset;
    sauria_axi4_lite_data_t psums_addr_offset;
   
    sauria_axi4_lite_data_t tile_offset_SRAMA;
    sauria_axi4_lite_data_t tile_offset_SRAMB;
    sauria_axi4_lite_data_t tile_offset_SRAMC;
    sauria_axi4_lite_data_t prev_tile_offset_SRAMC;

    sauria_axi4_addr_t      next_rd_addr;

    bit                     rd_tensors_done;
    bit                     ifmaps_done;
    bit                     weights_done;
    bit                     psums_done;
     
    bit                     update_prev_psums_tile_offset = 1'b1;
    bit                     psums_tile_wr_n_minus_1;

    function new(string name="sauria_tensor_ptr_model");
        super.new(name);
        message_id = "SAURIA_TENSOR_PTR_MODEL";
    endfunction

    virtual function sauria_axi4_addr_t get_next_exp_rd_address();
            
        if (rd_tensors_done) return sauria_axi4_addr_t'('hdeadbeef);
        else if (is_curr_tile_iter_done())begin 
            clear_done_signals();

            if (update_prev_psums_tile_offset) set_prev_SRAMC_tile_offset(); 
            
            case(loop_order)
                0: x_fastest_update_tile_counters();
                1: c_fastest_update_tile_counters();
                2: k_fastest_update_tile_counters();
            endcase
            `sauria_info(message_id, $sformatf("Tile Counters K: %0d C: %0d Y: %0d X: %0d", tile_K_counter, tile_C_counter, tile_Y_counter, tile_X_counter))
            
            update_tile_addr_offsets();
        end
        
        next_rd_addr = get_next_tiles_address();
        rd_tensors_done = is_done_getting_tensors_addresses();
        if(rd_tensors_done) clear_done_signals();
        
        return next_rd_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_exp_wr_address();
        update_prev_psums_tile_offset = 1'b1;   
        
        if (psums_tile_wr_n_minus_1 && psums_done)begin
            clear_done_signals();
            set_prev_SRAMC_tile_offset();
        end
        if (rd_tensors_done) psums_tile_wr_n_minus_1 = 1'b1;
            
        return get_next_wr_psums_address();
    endfunction

    virtual function sauria_axi4_addr_t get_next_tiles_address();    
        case(select_tensor())
            IFMAPS:  return get_next_rd_ifmaps_address();
            WEIGHTS: return get_next_rd_weights_address();
            PSUMS:   return get_next_rd_psums_address();
        endcase
    endfunction

    virtual function  sauria_tensor_type_t select_tensor();
        
        if (!ifmaps_done && !weights_done && !psums_done)begin
            if (get_ifmaps() || is_first_tile()) return IFMAPS;
            else begin
                ifmaps_done = 1'b1;
                return WEIGHTS;
            end
        end
        else if (ifmaps_done && get_weights() && !weights_done)
            return WEIGHTS;
        else if (ifmaps_done && (weights_done || !get_weights()) && get_psums() && !psums_done)
            return PSUMS;
    endfunction

    virtual function bit get_ifmaps();
        case(loop_order)
            0: return 1'b1;
            1: return 1'b1;
            2: return (tile_K_counter == 0);
        endcase
    endfunction

    virtual function bit get_weights();
        case(loop_order)
            0: return (tile_X_counter == 0) && (tile_Y_counter == 0);
            1: return 1'b1;
            2: return 1'b1;
        endcase
    endfunction

    virtual function bit get_psums();
        case(loop_order)
            0: return 1'b1;
            1: return (tile_C_counter == 0);
            2: return 1'b1;
        endcase
    endfunction

    virtual function bit is_curr_tile_iter_done();
        return ((tile_C_counter != 0) && (loop_order == 2'h1)) ? weights_done : psums_done;      
    endfunction 
    
    virtual function sauria_axi4_addr_t get_next_rd_ifmaps_address();
        sauria_axi4_addr_t next_ifmaps_addr;
        next_ifmaps_addr = get_ifmaps_row_addr(get_ifmaps_elem_aligned_address(get_ifmaps_addr_offset() + tile_offset_SRAMA));
        update_ifmaps_counters();   
        return  next_ifmaps_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_rd_weights_address();
        sauria_axi4_addr_t next_weights_addr;
        next_weights_addr = get_weights_row_addr(get_weights_elem_aligned_address(get_weights_addr_offset() + tile_offset_SRAMB));
        update_weights_counters();
        return next_weights_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_rd_psums_address();
        sauria_axi4_addr_t next_psums_addr;
        next_psums_addr = get_psums_row_addr(get_psums_elem_aligned_address(get_psums_addr_offset() + tile_offset_SRAMC));
        update_psums_counters();
        return next_psums_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_wr_psums_address();
        sauria_axi4_addr_t next_psums_addr;
        next_psums_addr = get_psums_row_addr(get_psums_elem_aligned_address(get_psums_addr_offset() + prev_tile_offset_SRAMC));
        update_psums_counters();

        return next_psums_addr;
    endfunction

    virtual function void update_ifmaps_counters();
        if ((ifmaps_y_counter == (ifmap_Y - 1)) && ((ifmaps_c_counter == (ifmap_C - 1)))) begin
            ifmaps_y_counter =  0;
            ifmaps_c_counter =  0;
            ifmaps_done      =  1'b1;
        end
        else if (ifmaps_y_counter == (ifmap_Y - 1))begin
            ifmaps_y_counter =  0;
            ifmaps_c_counter += 1;
        end
        else if (ifmaps_y_counter < ifmap_Y)begin
            ifmaps_y_counter += 1;
        end
    endfunction

    virtual function void update_weights_counters();
        if (weights_w_counter == (weights_W - 1))begin
            weights_w_counter = 0;
            weights_done = 1'b1;
        end
        else if (weights_w_counter < weights_W)begin
            weights_w_counter += 1;
        end
    endfunction

    virtual function void update_psums_counters();
        if ((psums_y_counter == (psums_Y - 1)) && ((psums_k_counter == (psums_K - 1)))) begin
            psums_y_counter =  0;
            psums_k_counter =  0;
            psums_done      =  1'b1;
        end
        else if (psums_y_counter == (psums_Y - 1))begin
            psums_y_counter =  0;
            psums_k_counter += 1;
        end
        else if (psums_y_counter < psums_Y)begin
            psums_y_counter += 1;
        end

    endfunction
   
    virtual function void update_tile_addr_offsets();
        tile_offset_SRAMA = get_SRAMA_tile_offset();
        tile_offset_SRAMB = get_SRAMB_tile_offset();
        tile_offset_SRAMC = get_SRAMC_tile_offset();
    endfunction

    virtual function void clear_done_signals();
        ifmaps_done  = 1'b0;
        weights_done = 1'b0;
        psums_done   = 1'b0;
    endfunction

    virtual function bit is_done_getting_tensors_addresses();
        return is_last_tile() && is_curr_tile_iter_done();
    endfunction

    virtual function bit is_last_tile();
        bit done_K = (tile_K_counter == (tile_K - 1) && (tile_K != 0)) || (tile_K == 0);
        bit done_C = (tile_C_counter == (tile_C - 1) && (tile_C != 0)) || (tile_C == 0);
        bit done_Y = (tile_Y_counter == (tile_Y - 1) && (tile_Y != 0)) || (tile_Y == 0);
        bit done_X = (tile_X_counter == (tile_X - 1) && (tile_X != 0)) || (tile_X == 0);
        return done_X && done_Y && done_C && done_K;
    endfunction

    virtual function void x_fastest_update_tile_counters();
        if ( (tile_C_counter == (tile_C - 1)) && (tile_Y_counter == (tile_Y - 1)) && (tile_X_counter == (tile_X - 1)) )begin
            tile_X_counter =  0;
            tile_Y_counter =  0;
            tile_C_counter =  0;
            tile_K_counter +=  1;
        end
        else if ( (tile_Y_counter == (tile_Y - 1)) && (tile_X_counter == (tile_X - 1)) )begin 
            tile_X_counter =  0;
            tile_Y_counter =  0;
            tile_C_counter += 1;
        end
        else if ((tile_X_counter == (tile_X - 1)) )begin 
            tile_X_counter  =  0;
            tile_Y_counter += 1;
        end
        else if (tile_X_counter < (tile_X))begin
            tile_X_counter += 1;
        end
    endfunction

    virtual function void c_fastest_update_tile_counters();
        if ( (tile_C_counter == (tile_C - 1)) && (tile_K_counter == (tile_K - 1)) && (tile_X_counter == (tile_X - 1))  )begin
            tile_C_counter =  0;
            tile_K_counter =  0;
            tile_X_counter =  0;
            tile_Y_counter +=  1;
        end
        else if ( (tile_C_counter == (tile_C - 1) && (tile_K_counter == (tile_K - 1)) ) )begin 
            tile_C_counter =  0;
            tile_K_counter =  0;
            tile_X_counter += 1;
        end
        else if ((tile_C_counter == (tile_C - 1)) )begin 
            tile_C_counter  =  0;
            tile_K_counter += 1;
        end
        else if (tile_C_counter < (tile_C))begin
            tile_C_counter += 1;
        end
    endfunction

    virtual function void k_fastest_update_tile_counters();
        if ( (tile_C_counter == (tile_C - 1)) && (tile_K_counter == (tile_K - 1)) && (tile_X_counter == (tile_X - 1))  )begin
            tile_C_counter =  0;
            tile_K_counter =  0;
            tile_X_counter =  0;
            tile_Y_counter +=  1;
        end
        else if ( (tile_K_counter == (tile_K - 1)) && (tile_C_counter == (tile_C - 1)) )begin 
            tile_K_counter =  0;
            tile_C_counter =  0;
            tile_X_counter += 1;
        end
        else if ((tile_K_counter == (tile_K - 1)) )begin 
            tile_K_counter  =  0;
            tile_C_counter += 1;
        end
        else if (tile_K_counter < (tile_K))begin
            tile_K_counter += 1;
        end

    endfunction

    virtual function sauria_axi4_addr_t get_ifmaps_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMA_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_weights_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMB_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_psums_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMC_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_ifmaps_addr_offset();
        return sauria_axi4_addr_t'((ifmaps_c_counter*ifmap_Y*ifmap_X) + (ifmaps_y_counter*ifmap_X));
    endfunction

    virtual function sauria_axi4_addr_t get_weights_addr_offset();
        return sauria_axi4_addr_t'( weights_w_counter*weights_K);
    endfunction

    virtual function sauria_axi4_addr_t get_psums_addr_offset();
        return sauria_axi4_addr_t'((psums_k_counter * seq_psums_Y * psums_X) + (psums_y_counter*psums_X)); 
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMA_tile_offset();
        return sauria_axi4_addr_t'(ifmaps_tile_size * get_ifmaps_tile_idx());
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMB_tile_offset();
        return sauria_axi4_addr_t'(weights_tile_size  * get_weights_tile_idx());
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMC_tile_offset();
        return sauria_axi4_addr_t'(psums_tile_size * get_psums_tile_idx());
    endfunction

    virtual function void set_prev_SRAMC_tile_offset();
        update_prev_psums_tile_offset = 1'b0;
        prev_tile_offset_SRAMC =  get_SRAMC_tile_offset();
    endfunction

    virtual function int get_ifmaps_tile_idx();
        return (tile_C_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
    endfunction

    virtual function int get_weights_tile_idx();
        return (tile_K_counter * tile_C) + tile_C_counter;
    endfunction

    virtual function int get_psums_tile_idx();
        return  (tile_K_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
    endfunction

    virtual function sauria_axi4_addr_t get_ifmaps_elem_aligned_address(int offset);
        return sauria_axi4_addr_t'(offset * df_ctrl_pkg::A_BYTES);
    endfunction

    virtual function sauria_axi4_addr_t get_weights_elem_aligned_address(int offset);
        return sauria_axi4_addr_t'(offset * df_ctrl_pkg::B_BYTES);
    endfunction

    virtual function sauria_axi4_addr_t get_psums_elem_aligned_address(int offset);
        return sauria_axi4_addr_t'(offset * df_ctrl_pkg::C_BYTES);
    endfunction

    function bit at_K_boundary();
        return (tile_K_counter != 0) && (tile_C_counter == 0) && (tile_Y_counter == 0) && (tile_X_counter == 0);
    endfunction

    function bit at_C_boundary();
        return (tile_C_counter != 0) && (tile_Y_counter == 0) && (tile_X_counter == 0);
    endfunction

    function bit at_Y_boundary();
        return (tile_Y_counter != 0) && (tile_X_counter == 0);
    endfunction

    function bit at_X_boundary();
        return tile_X_counter != 0;
    endfunction

    virtual function bit is_first_tile();
        return (tile_K_counter == 0) && (tile_C_counter == 0) && (tile_Y_counter == 0) && (tile_X_counter == 0);
    endfunction

endclass