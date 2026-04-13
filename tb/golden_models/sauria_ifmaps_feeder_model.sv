class sauria_ifmaps_feeder_model extends uvm_object;

    `uvm_object_utils(sauria_ifmaps_feeder_model)

    string message_id = "SAURIA_IFMAPS_FEEDER_MODEL";

    ifmaps_params_t         ifmaps_params;
    arr_col_data_t          ifmaps_rows_active;
    sauria_axi4_lite_data_t c_idx, x_idx, y_idx;
  
    srama_addr_t            exp_next_srama_addr;   
    ifmaps_feeder_data_t    feeder_data[$];
    ifmaps_feeder_data_t    feeder_data_inst;
    ifmaps_feeder_data_t    popped_inst;

    bit                     valid_entry_srama_addr_accessed;
    bit                     valid_entry_srama_data_accessed;
    bit                     valid_entry_a_arr_data_accessed;
      
    function new(string name="sauria_ifmaps_feeder_model");
        super.new(name);
    endfunction

    virtual function void configure(ifmaps_params_t ifmaps_params, arr_col_data_t ifmaps_rows_active);
        this.ifmaps_params      = ifmaps_params;
        this.ifmaps_rows_active = ifmaps_rows_active;
    endfunction

    virtual function void reset_model();
        feeder_data.delete();
        exp_next_srama_addr = srama_addr_t'(0);
        clear_counters();
    endfunction

    virtual function void add_ifmaps_sram_access(ifmaps_feeder_data_t ifmaps_feeder_data);   
        feeder_data.push_back(ifmaps_feeder_data);
        update_exp_srama_rd_addr();
    endfunction

    virtual function void add_ifmaps_systolic_feed_data(a_arr_data_t a_arr);
        if (feeder_data.size() > 0)begin
            update_feeder_data(a_arr);        
        end
        else `sauria_error(message_id, "IFMAPS Feeder Fed Data Without Reading From SRAMA")

    endfunction
    
    /*---------------------Address Helper Function------------------- */
    virtual function void update_exp_srama_rd_addr();
        update_counters();
        set_counter_based_exp_addr();
    endfunction
    
    virtual function void set_counter_based_exp_addr();
        exp_next_srama_addr = (c_idx + x_idx + y_idx) / SRAMA_N;    
    endfunction

    virtual function void update_counters();
        if ((c_idx + ifmaps_params.tile_params.ifmaps_c_step) 
            < ifmaps_params.tile_params.ifmaps_C)begin
            c_idx += ifmaps_params.tile_params.ifmaps_c_step;
        
        end
        else if ((x_idx + ifmaps_params.tile_params.ifmaps_x_step) 
            < ifmaps_params.tile_params.ifmaps_X)begin
            c_idx = 0;
            x_idx += ifmaps_params.tile_params.ifmaps_x_step;
        end
        else if ((y_idx + ifmaps_params.tile_params.ifmaps_y_step) 
            < ifmaps_params.tile_params.ifmaps_Y)begin
            c_idx = 0;
            x_idx = 0;    
            y_idx += ifmaps_params.tile_params.ifmaps_y_step;
        end
        else begin
            c_idx = 0;
            x_idx = 0;
            y_idx = 0;
        end

    endfunction

    virtual function srama_addr_t get_next_exp_srama_rd_addr();
        return exp_next_srama_addr;
    endfunction

    virtual function sauria_axi4_lite_data_t get_c_idx();
        return c_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_x_idx();
        return x_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_y_idx();
        return y_idx;
    endfunction

    /*------------------------------------------------------------- */
    
    /*---------------------Data Helper Function --------------------*/
    
    virtual function void update_feeder_data(a_arr_data_t a_arr);
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::Y) ? feeder_data.size() : sauria_pkg::Y;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::Y; row++)begin
                //Find first invalid element
                if(!feeder_data[i].arr_byte_valid[row]) begin
                    feeder_data[i].arr_byte_valid[row] = 1'b1; //Set To Valid
                    feeder_data[i].a_arr[row]          = a_arr[row];
                    
                    if (i == 0) last_valid_queue_elem  = row + 1;
                    
                    `sauria_info(message_id, $sformatf("Valid a_arr_row[%0d]: 0x%0h Entry_Val: 0x%0h",
                    row, a_arr[row], a_arr))
                    break;    
                end
            end
            
        end
    endfunction

    virtual function a_arr_data_t get_reversed_array_bus(a_arr_data_t a_arr);
        a_arr_data_t reversed_bus;
        for(int row=0; row < sauria_pkg::Y; row++)begin
            reversed_bus[row] = a_arr[sauria_pkg::Y - 1 - row];
        end
        return reversed_bus;
    endfunction

    virtual function a_arr_data_t get_masked_inactive_rows_data(a_arr_data_t a_arr);
        a_arr_data_t masked_row_data;
        arr_col_data_rev_t rev_ifmaps_rows_active  = ifmaps_rows_active;

        for(int row=0; row < sauria_pkg::Y; row++)begin
            masked_row_data[row] = (rev_ifmaps_rows_active[row] == 1'b1) ? a_arr[row] : 0;

            if (ifmaps_rows_active[row] == 1'b1) `sauria_info(message_id, $sformatf("IFMAPS_ROWS_ACTIVE ROW: %0d", row))
        end
        return masked_row_data;
    
    endfunction

    virtual function void clear_arr_byte_valids();
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::Y) ? feeder_data.size() : sauria_pkg::Y;
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::Y; row++)begin
                feeder_data[i].arr_byte_valid[row] = 1'b0;
            end
        end
    endfunction

    virtual function bit has_valid_entry();
        return $countones(feeder_data[0].arr_byte_valid) == sauria_pkg::Y;
    endfunction

    virtual function srama_addr_t get_valid_entry_srama_addr();
        valid_entry_srama_addr_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        pop_valid_entry();
        return feeder_data_inst.srama_addr;
    endfunction

    virtual function srama_data_t get_valid_srama_data();
        valid_entry_srama_data_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        pop_valid_entry();
        return get_masked_inactive_rows_data(feeder_data_inst.srama_data);
    endfunction
 
    virtual function a_arr_data_t get_valid_a_arr_data();
        valid_entry_a_arr_data_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        `sauria_info(message_id, $sformatf("Getting A_ARR_Data: 0x%0h Reversed: 0x%0h", feeder_data_inst.a_arr, get_reversed_array_bus(feeder_data_inst.a_arr)))
        pop_valid_entry();
        return get_reversed_array_bus(feeder_data_inst.a_arr);
    endfunction

    virtual function void pop_valid_entry();
        if (valid_entry_srama_addr_accessed &&
            valid_entry_srama_data_accessed &&
            valid_entry_a_arr_data_accessed) begin

            valid_entry_srama_addr_accessed = 1'b0;
            valid_entry_srama_data_accessed = 1'b0;
            valid_entry_a_arr_data_accessed = 1'b0;
            popped_inst = feeder_data.pop_front();

        end
    endfunction

    virtual function void clear_counters();
        c_idx = 0;
        x_idx = 0;
        y_idx = 0;
    endfunction

     /*-------------------------------------------------- */

endclass