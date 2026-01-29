class tensor_ptr_model extends uvm_object;

    `uvm_object_utils(tensor_ptr_model)

    string message_id           = "SAURIA_TENSOR_PTR_MODEL";

    sauria_axi4_addr_t               row_addr;
    
    sauria_axi4_addr_t               awaddr; 
    rand sauria_ifmaps_elem_data_t   ifmaps_elem_data;
    rand sauria_weights_elem_data_t  weights_elem_data;
    rand sauria_psums_elem_data_t    psums_elem_data;
    
    sauria_axi4_lite_data_t          start_SRAMA_addr;
    sauria_axi4_lite_data_t          start_SRAMB_addr;
    sauria_axi4_lite_data_t          start_SRAMC_addr;

    sauria_axi4_lite_data_t          tile_offset_SRAMA;
    sauria_axi4_lite_data_t          tile_offset_SRAMB;
    sauria_axi4_lite_data_t          tile_offset_SRAMC;

    int                              ifmaps_tile_size;
    int                              weights_tile_size;
    int                              psums_tile_size;

    int                              ifmap_addr_offset;
    int                              weights_addr_offset;
    int                              psums_addr_offset;
    
    int                              ifmaps_y_counter;
    int                              ifmaps_c_counter;
    int                              weights_w_counter;
    int                              psums_y_counter;
    int                              psums_k_counter;
   
    int                              ifmap_X;
    int                              ifmap_Y;
    int                              ifmap_C;
                                
    int                              weights_W;
    int                              weights_K;

    int                              psums_X;
    int                              psums_Y;
    int                              psums_K;
    
    int                              tile_X;
    int                              tile_Y;
    int                              tile_C;
    int                              tile_K;

    int                              tile_weights_C;

    int                              tile_X_counter;
    int                              tile_Y_counter;
    int                              tile_C_counter;
    int                              tile_K_counter;
    
    bit                              single_tile;
    bit                              done;

    bit                              should_get_weights_addresses;
   
    bit                              ifmaps_done   = 1'b0;
    bit                              weights_done  = 1'b0;
    bit                              psums_done    = 1'b0;
     
    function new(string name="tensor_ptr_model");
        super.new(name);
    endfunction

    virtual function sauria_axi4_addr_t get_next_exp_address();
        should_get_weights_addresses = (tile_X_counter == 0) && (tile_Y_counter == 0);
        done = is_done_getting_tensors_addresses();
            
        if (done) return sauria_axi4_addr_t'('hdeadbeef);
        else if (!single_tile && (psums_done))begin
            `sauria_info(message_id, $sformatf("Tile Counters K: %0d C: %0d Y: %0d X: %0d", tile_K_counter, tile_C_counter, tile_Y_counter, tile_X_counter))
            clear_done_signals();
            update_tile_counters();
            update_tile_addr_offsets();
        end
            
        done = single_tile;
        return get_next_tiles_address();
    endfunction

    virtual function sauria_axi4_addr_t get_next_tiles_address();    
        case(select_tensor())
            IFMAPS:  return get_next_ifmaps_address();
            WEIGHTS: return get_next_weights_address();
            PSUMS:   return get_next_psums_address();
        endcase
    endfunction

    virtual function  sauria_tensor_type_t select_tensor();
        if (!ifmaps_done && !weights_done && !psums_done)
            return IFMAPS;
        else if (ifmaps_done && should_get_weights_addresses && !weights_done)
            return WEIGHTS;
        else if (ifmaps_done && should_get_weights_addresses && weights_done && !psums_done)
            return PSUMS;
        else if (ifmaps_done && !should_get_weights_addresses && !psums_done)
            return PSUMS;
    endfunction

    virtual function sauria_axi4_addr_t get_next_ifmaps_address();
        sauria_axi4_addr_t next_ifmaps_addr;
        ifmap_addr_offset = (ifmaps_c_counter*ifmap_Y*ifmap_X) + (ifmaps_y_counter*ifmap_X);
        next_ifmaps_addr = get_ifmaps_row_addr(get_ifmaps_elem_aligned_address(ifmap_addr_offset + tile_offset_SRAMA));
        update_ifmaps_counters();   
        return  next_ifmaps_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_weights_address();
        sauria_axi4_addr_t next_weights_addr;
        weights_addr_offset = (weights_w_counter*weights_K);
        next_weights_addr = get_weights_row_addr(get_weights_elem_aligned_address(weights_addr_offset + tile_offset_SRAMB));
        update_weights_counters();
        return next_weights_addr;
    endfunction

    virtual function sauria_axi4_addr_t get_next_psums_address();
        sauria_axi4_addr_t next_psums_addr;
        psums_addr_offset = (psums_k_counter * psums_Y * psums_X) + (psums_y_counter*psums_X); 
        next_psums_addr = get_psums_row_addr(get_psums_elem_aligned_address(psums_addr_offset + tile_offset_SRAMC));
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
   
    virtual function void clear_done_signals();
        ifmaps_done  = 1'b0;
        weights_done = 1'b0;
        psums_done   = 1'b0;
    endfunction

    virtual function bit is_done_getting_tensors_addresses();
        bit done_K = (tile_K_counter == tile_K && tile_K != 0);
        bit done_C = (tile_K == 0) && (tile_C_counter == tile_C) && (tile_C != 0);
        bit done_Y = (tile_K == 0) && (tile_C == 0) && (tile_Y_counter == tile_Y) && (tile_Y != 0);
        bit done_X = (tile_K == 0) && (tile_C == 0) && (tile_Y == 0) && (tile_X_counter == tile_X) && (tile_X != 0);
        return done_X || done_Y || done_C || done_K;
    endfunction

    virtual function void update_tile_counters();
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

    virtual function void update_tile_addr_offsets();
        tile_offset_SRAMA = get_SRAMA_tile_offset();
        tile_offset_SRAMB = get_SRAMB_tile_offset();
        tile_offset_SRAMC = get_SRAMC_tile_offset();
    endfunction

    virtual function void configure_model(sauria_computation_params computation_params);
        set_tensor_start_addr(computation_params);
        set_tensor_dimensions(computation_params);
        set_tile_sizes(computation_params);
    endfunction

    virtual function void set_tensor_start_addr(sauria_computation_params computation_params);
        start_SRAMA_addr = computation_params.start_SRAMA_addr;
        start_SRAMB_addr = computation_params.start_SRAMB_addr;
        start_SRAMC_addr = computation_params.start_SRAMC_addr;
    endfunction

    virtual function void set_tensor_dimensions(sauria_computation_params computation_params);

        `sauria_info(message_id, "Getting Computation Params")
        ifmap_X   = computation_params.ifmaps_X;
        ifmap_Y   = computation_params.ifmaps_Y + 1; //From limit
        ifmap_C   = computation_params.ifmaps_C + 1; //From limit

        weights_W = computation_params.weights_W;
        weights_K = computation_params.weights_K;

        psums_X   = computation_params.psums_X;
        psums_Y   = computation_params.psums_Y + 1; //From limit
        psums_K   = computation_params.psums_K;

        tile_X    = computation_params.tile_X;
        tile_Y    = computation_params.tile_Y;
        tile_C    = computation_params.tile_C;
        tile_K    = computation_params.tile_K;

        single_tile = is_single_tile();
        
        `sauria_info(message_id, $sformatf("Tile Dimensions K: %0d C: %0d Y: %0d X: %0d", tile_K, tile_C, tile_Y, tile_X))
        `sauria_info(message_id, $sformatf("IFMAPS Dimensions C: %0d Y: %0d X: %0d", ifmap_C, ifmap_Y, ifmap_X))
        `sauria_info(message_id, $sformatf("WEIGHTS Dimensions W: %0d K: %0d", weights_W, weights_K))
        `sauria_info(message_id, $sformatf("PSUMS Dimensions K: %0d Y: %0d X: %0d", psums_K, psums_Y, psums_X))
    endfunction

    virtual function void set_tile_sizes(sauria_computation_params computation_params);
        ifmaps_tile_size  = computation_params.get_ifmaps_tile_size();
        weights_tile_size = computation_params.get_weights_tile_size();
        psums_tile_size   = computation_params.get_psums_tile_size(); 
    endfunction

    virtual function bit is_single_tile();
        return (tile_K == 0) && (tile_C == 0) && (tile_Y == 0) && (tile_X == 0);
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

    virtual function sauria_axi4_addr_t get_ifmaps_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMA_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_weights_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMB_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_psums_row_addr(sauria_axi4_addr_t awaddr);
        return sauria_axi4_addr_t'(start_SRAMC_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMA_tile_offset();
        int multiplier = (tile_C_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
        return ifmaps_tile_size * multiplier;
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMB_tile_offset();
        int mutiplier = (tile_K_counter * tile_C) + tile_C_counter;
        return weights_tile_size  * mutiplier;
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMC_tile_offset();
        int multiplier = (tile_K_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
        return psums_tile_size * multiplier;
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

endclass