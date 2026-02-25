class sauria_axi4_mem_base_seq extends uvm_sequence #(sauria_tensor_mem_seq_item);

    `uvm_object_utils(sauria_axi4_mem_base_seq)

    string message_id           = "SAURIA_AXI4_MEM_BASE_SEQ";

    sauria_tensor_mem_seq_item       tensor_mem_seq_item;
    sauria_computation_params        computation_params;

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

    int                              weights_base_addr_offset;
    int                              psums_base_addr_offset;
    
    int                              ifmap_addr_offset;
    int                              weights_addr_offset;
    int                              psums_addr_offset;
    
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
   
    bit                              should_send_ifmaps;
    bit                              should_send_weights;
    bit                              should_send_psums;
     
    int                              arvalid_count;
    df_ctrl_substate_t               curr_df_ctrl_substate;
   
    virtual sauria_subsystem_ifc     sauria_ss_if;
    virtual sauria_df_controller_ifc sauria_df_ctrl_if;
    virtual sauria_axi4_ifc          sauria_axi4_mem_if;

    function new(string name="sauria_axi4_mem_base_seq");
        super.new(name);

        if (!uvm_config_db #(virtual sauria_df_controller_ifc)::get(m_sequencer, "", "sauria_df_ctrl_if", sauria_df_ctrl_if))
            `sauria_error(message_id, "Failed to get access to sauria_df_ctrl_if")

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(m_sequencer, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(m_sequencer, "", "sauria_axi4_mem_if", sauria_axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to sauria_axi4_mem_if")

    endfunction

    task body();
        get_computation_params();
        `sauria_info(message_id,  "Calling MEM SEQ")
        send_tensors();
    endtask

    virtual task get_computation_params();
        get_computation_params_access();
        get_tensor_start_addr();
        get_tensor_dimensions();
    endtask

    virtual function void get_computation_params_access();
        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    endfunction

    virtual task get_tensor_start_addr();
        wait(computation_params.tensors_start_addr_shared);
       
        start_SRAMA_addr = computation_params.start_SRAMA_addr;
        start_SRAMB_addr = computation_params.start_SRAMB_addr;
        start_SRAMC_addr = computation_params.start_SRAMC_addr;
    endtask

    virtual task get_tensor_dimensions();
     
        `sauria_info(message_id, "Getting Computation Params")
        wait(computation_params.shared);
        ifmap_X   = computation_params.ifmaps_X;
        ifmap_Y   = computation_params.ifmaps_Y; 
        ifmap_C   = computation_params.ifmaps_C; 

        weights_W = computation_params.weights_W;
        weights_K = computation_params.weights_K;

        psums_X   = computation_params.psums_X;
        psums_Y   = computation_params.psums_Y; 
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
    endtask

    virtual task print_active();
        forever @ (posedge sauria_df_ctrl_if.dma_tile_ptr_advance) begin
            `sauria_info(message_id, $sformatf("Tile Pointer Advance ARVALID_COUNT: %0d", arvalid_count))
        end
    endtask

    virtual task get_rvalid_count();
        forever @ (posedge sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid)begin
            arvalid_count += 1;
        end
    endtask

    virtual task get_rvalids_per_substate();
        forever @ (posedge sauria_ss_if.i_system_clk) begin
            if (curr_df_ctrl_substate != sauria_df_ctrl_if.df_ctrl_substate)begin
                `sauria_info(message_id, $sformatf("Substate: %0s ARVALID Count: %0d", curr_df_ctrl_substate, arvalid_count))
                arvalid_count = 0;
            end
            curr_df_ctrl_substate = sauria_df_ctrl_if.df_ctrl_substate;
        end
    endtask

    virtual task send_tensors();
            
        while(!done)begin
            should_send_ifmaps  =  1'b1; //tile_K_counter == 0; FIXME: wilsalv : For loop_order = 0
            should_send_weights = (tile_X_counter == 0) && (tile_Y_counter == 0);
            should_send_psums   =  1'b1; // tile_C_counter == 0;

            `sauria_info(message_id, $sformatf("Tile Counters K: %0d C: %0d Y: %0d X: %0d", tile_K_counter, tile_C_counter, tile_Y_counter, tile_X_counter))
            done = is_done_sending_tensors();
            if (done) continue;
            else if (!single_tile)begin
                update_tile_addr_offsets();
                `sauria_info(message_id, $sformatf("SRAMA_TileOffset: 0x%0h", tile_offset_SRAMA))
                update_tile_counters();
                if (at_K_boundary() || at_C_boundary() || at_Y_boundary()) continue;
            end
            
            send_tiles(should_send_weights);
            done = single_tile;
        end
    endtask

    virtual task send_tiles(bit should_send_weights);    
        if (should_send_ifmaps)  send_ifmap();
        if (should_send_weights) send_weights();
        if (should_send_psums)   send_psums();
    endtask

    virtual function bit is_done_sending_tensors();
        bit done_K = (tile_K_counter == tile_K && tile_K != 0);
        bit done_C = (tile_K == 0) && (tile_C_counter == tile_C) && (tile_C != 0);
        bit done_Y = (tile_K == 0) && (tile_C == 0) && (tile_Y_counter == tile_Y) && (tile_Y != 0);
        bit done_X = (tile_K == 0) && (tile_C == 0) && (tile_Y == 0) && (tile_X_counter == tile_X) && (tile_X != 0);
        return done_X || done_Y || done_C || done_K;
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

    virtual function void update_tile_counters();
        if ( (tile_C_counter == (tile_C) ) )begin
            tile_X_counter =  0;
            tile_Y_counter =  0;
            tile_C_counter =  0;
            tile_K_counter +=  1;
        end
        else if  ( (tile_Y_counter == (tile_Y)) )begin 
            tile_X_counter =  0;
            tile_Y_counter =  0;
            tile_C_counter += 1;
        end
        else if ((tile_X_counter == (tile_X)) )begin 
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

    virtual task send_ifmap();

        `sauria_info(message_id, "Starting IFMAPS")
        for(int c=0; c < ifmap_C; c++)begin
            for(int y=0; y < ifmap_Y; y++)begin
                
                create_tensor_seq_item_with_name($sformatf("IFMAP_C%0d_Y%0d", c, y));
                start_item(tensor_mem_seq_item); 
                ifmap_addr_offset = (c*ifmap_Y*ifmap_X) + (y*ifmap_X);
               
                tensor_mem_seq_item.tensor_type = IFMAPS;
                set_ifmaps_row_addr(get_ifmaps_elem_aligned_address(ifmap_addr_offset + tile_offset_SRAMA));
    
                for(int x=0; x < ifmap_X; x++)begin
                    if (!this.randomize()) begin
                        `sauria_error(message_id, "Failed to randomize sauria_axi4_mem_base_seq")
                    end
                    add_ifmaps_elem(ifmaps_elem_data);
                end
                finish_item(tensor_mem_seq_item);
                
            end
        end
        `sauria_info(message_id, "Done IFMAPS")
        
    endtask

    virtual task send_weights();
        
        `sauria_info(message_id, "Starting WEIGHTS")
        
        for(int w=0; w < weights_W; w++)begin
           
            create_tensor_seq_item_with_name($sformatf("WEIGHTS_W%0d", w));
            start_item(tensor_mem_seq_item); 
               
            weights_addr_offset = (w*weights_K);
            set_weights_row_addr(get_weights_elem_aligned_address(weights_addr_offset + tile_offset_SRAMB));
            
            tensor_mem_seq_item.tensor_type = WEIGHTS;
            
            for(int k=0; k < weights_K; k++)begin
                
                if (!this.randomize())
                    `sauria_error(message_id, "Failed to randomize sauria_axi4_mem_base_seq")
                
                add_weights_elem(weights_elem_data);
            end
            finish_item(tensor_mem_seq_item);
        end

        psums_base_addr_offset = weights_addr_offset + weights_K;
        `sauria_info(message_id, "Done WEIGHTS")
        
    endtask

    virtual task send_psums();

        `sauria_info(message_id, "Starting PSUMS")
        
        for(int k=0; k < psums_K; k++)begin
            for(int y=0; y < psums_Y; y++)begin
                
                create_tensor_seq_item_with_name($sformatf("PSUMS_K%0d_Y%0d", k, y));
                start_item(tensor_mem_seq_item); 
                
                psums_addr_offset = (k * psums_Y * psums_X) + (y*psums_X); 
                tensor_mem_seq_item.tensor_type = PSUMS;
                set_psums_row_addr(get_psums_elem_aligned_address(psums_addr_offset + tile_offset_SRAMC));
    
                for(int x=0; x < psums_X; x++)begin
                    if (!this.randomize()) begin
                        `sauria_error(message_id, "Failed to randomize sauria_axi4_mem_base_seq")
                    end
                    add_psums_elem(psums_elem_data);
                end
                finish_item(tensor_mem_seq_item);
                
            end
        end

        `sauria_info(message_id, "Done PSUMS")
    endtask

    virtual function void create_tensor_seq_item_with_name(string name);
        tensor_mem_seq_item = sauria_tensor_mem_seq_item::type_id::create(name);
    endfunction

    virtual function void set_ifmaps_row_addr(sauria_axi4_addr_t awaddr);
        tensor_mem_seq_item.row_addr = sauria_axi4_addr_t'(start_SRAMA_addr + awaddr); 
    endfunction

    virtual function void set_weights_row_addr(sauria_axi4_addr_t awaddr);
        tensor_mem_seq_item.row_addr = sauria_axi4_addr_t'(start_SRAMB_addr + awaddr); 
    endfunction

    virtual function void set_psums_row_addr(sauria_axi4_addr_t awaddr);
        tensor_mem_seq_item.row_addr = sauria_axi4_addr_t'(start_SRAMC_addr + awaddr); 
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMA_tile_offset();
        int multiplier = (tile_C_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
        return computation_params.get_ifmaps_tile_size() * multiplier;
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMB_tile_offset();
        int mutiplier = (tile_K_counter * tile_C) + tile_C_counter;
        return computation_params.get_weights_tile_size()  * mutiplier;
    endfunction

    virtual function sauria_axi4_addr_t get_SRAMC_tile_offset();
        int multiplier = (tile_K_counter * tile_Y * tile_X) + (tile_Y_counter * tile_X) + tile_X_counter;
        return computation_params.get_psums_tile_size * multiplier;
    endfunction

    virtual function void add_ifmaps_elem(sauria_ifmaps_elem_data_t ifmaps_elem_data);
        tensor_mem_seq_item.ifmaps_elems.push_back(ifmaps_elem_data);
    endfunction

    virtual function void add_weights_elem(sauria_weights_elem_data_t weights_elem_data);
        tensor_mem_seq_item.weights_elems.push_back(weights_elem_data);
    endfunction

    virtual function void add_psums_elem(sauria_psums_elem_data_t psums_elem_data);
        tensor_mem_seq_item.psums_elems.push_back(psums_elem_data);
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