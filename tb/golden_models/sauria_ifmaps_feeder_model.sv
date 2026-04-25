class sauria_ifmaps_feeder_model extends sauria_feeder_base_model;

    `uvm_object_utils(sauria_ifmaps_feeder_model)

    ifmaps_params_t         ifmaps_params;
    arr_col_data_t          ifmaps_rows_active;
    sauria_axi4_lite_data_t c_idx, x_idx, y_idx;
  
    srama_addr_t            exp_next_srama_addr;   
    ifmaps_feeder_data_t    feeder_data[$];
    ifmaps_feeder_data_t    feeder_data_inst;
    bit                     ifmaps_feeding_not_done;
      
    function new(string name="sauria_ifmaps_feeder_model");
        super.new(name);
        set_message_id("SAURIA_IFMAPS_FEEDER_MODEL");
    endfunction

    virtual function void configure(ifmaps_params_t ifmaps_params, arr_col_data_t ifmaps_rows_active);
        this.ifmaps_params      = ifmaps_params;
        this.ifmaps_rows_active = ifmaps_rows_active;
        is_configured           = 1'b1;
    endfunction

    virtual function void reset_model();
        feeder_data.delete();
        reset_overlap_tracking();
        exp_next_srama_addr = srama_addr_t'(0);
        clear_counters();
    endfunction

    virtual function ifmaps_feeder_srama_access_result_t observe_srama_access(ifmaps_feeder_data_t ifmaps_feeder_data,
                                                                              bit                  til_done);
        ifmaps_feeder_srama_access_result_t result = '{default:'0};

        ensure_configured();

        if (til_done) begin
            result.c_idx = c_idx;
            result.x_idx = x_idx;
            result.y_idx = y_idx;
            result.tile_done_counter_mismatch = !are_tile_done_counters_cleared();
        end

        result.exp_srama_addr = exp_next_srama_addr;
        result.addr_mismatch  = (result.exp_srama_addr != ifmaps_feeder_data.srama_addr);

        add_ifmaps_sram_access(ifmaps_feeder_data);

        return result;
    endfunction

    virtual function ifmaps_feeder_arr_feed_result_t observe_arr_feed(a_arr_data_t a_arr,
                                                                      bit          start_feeding,                                                          bit          pop_en,
                                                                      bit          fifo_empty);
        
        ifmaps_feeder_arr_feed_result_t result = '{default:'0};

        ensure_configured();

        if (start_feeding)
            set_overlapping_comp();

        add_ifmaps_systolic_feed_data(a_arr);

        if (has_valid_entry() && !fifo_empty)
            result = get_valid_entry();

        if (!(pop_en || is_overlapping_comps()))
            clear_arr_byte_valids();

        update_comp_indeces();

        return result;
    endfunction

    virtual function void set_incntlim(sauria_axi4_lite_data_t incntlim);
        set_incntlim_and_comp_feeding_len(incntlim, sauria_pkg::Y);
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

    virtual function bit are_tile_done_counters_cleared();
        return (c_idx == srama_addr_t'(0)) &&
               (x_idx == srama_addr_t'(0)) &&
               (y_idx == srama_addr_t'(0));
    endfunction

    /*------------------------------------------------------------- */
    
    /*---------------------Data Helper Function --------------------*/
    
    virtual function void update_feeder_data(a_arr_data_t a_arr);
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::Y) ? feeder_data.size() : sauria_pkg::Y;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            if ((i == sauria_pkg::Y - 1 - (idx_curr_comp - incntlim)) &&
                (idx_curr_comp >= incntlim) &&
                (idx_curr_comp != (comp_feeding_len - 1)) &&
                (!overlapping_comps))
                break;

            for(int row=0; row < sauria_pkg::Y; row++)begin
                //Find first invalid element
                if(!feeder_data[i].arr_byte_valid[row]) begin
                    feeder_data[i].arr_byte_valid[row] = 1'b1; //Set To Valid
                    feeder_data[i].a_arr[row]          = a_arr[row];
                    
                    if ((i == 0) && (row < last_valid_queue_elem)) begin
                        last_valid_queue_elem = row + 1;
                    end
                    else if ((overlapping_comps) && (row == 0)) begin
                        `sauria_info(message_id, $sformatf("Overlapping Comps Found Idx: %0d Row: %0d Last_Valid_Elem_Before: %0d Last_Valid_Elem_After: %0d",
                        i, row, last_valid_queue_elem, i))

                        last_valid_queue_elem = i;
                    end
                    
                    `sauria_info(message_id, $sformatf("Elem_Idx: %0d Valid a_arr_row[%0d]: 0x%0h Entry_Val: 0x%0h",
                    i, row, a_arr[row], a_arr))
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
        return (feeder_data.size() > 0) &&
               ($countones(feeder_data[0].arr_byte_valid) == sauria_pkg::Y);
    endfunction

    virtual function void set_overlapping_comp();
        ifmaps_feeding_not_done = (idx_curr_comp >= incntlim) && (idx_curr_comp < (comp_feeding_len - 1));
        overlapping_comps       = ifmaps_feeding_not_done;
        `sauria_info(message_id, $sformatf("Ifmaps Feeding Started Overlapping_Comps: %0d Comp_Idx: %0d", overlapping_comps, idx_curr_comp))
    endfunction

    virtual function bit is_overlapping_comps();
        return overlapping_comps;
    endfunction

    virtual function void update_comp_indeces();
        idx_curr_comp = ((overlapping_comps == 1'b1) && (idx_curr_comp == (comp_feeding_len - 2))) ? idx_next_comp + 1 : (idx_curr_comp + 1) % comp_feeding_len;
        idx_next_comp = (overlapping_comps == 1'b1) ? idx_next_comp + 1 : 0;

        if (idx_curr_comp == idx_next_comp)
            overlapping_comps = 1'b0;
    endfunction

    virtual function ifmaps_feeder_arr_feed_result_t get_valid_entry();
        ifmaps_feeder_arr_feed_result_t result = '{default:'0};

        feeder_data_inst       = feeder_data.pop_front();
        result.valid_entry     = 1'b1;
        result.srama_addr      = feeder_data_inst.srama_addr;
        result.exp_srama_data  = get_masked_inactive_rows_data(feeder_data_inst.srama_data);
        result.exp_a_arr_data  = get_reversed_array_bus(feeder_data_inst.a_arr);

        `sauria_info(message_id, $sformatf("Getting A_ARR_Data: 0x%0h Reversed: 0x%0h",
        feeder_data_inst.a_arr, result.exp_a_arr_data))

        return result;
    endfunction

    virtual function void clear_counters();
        c_idx = 0;
        x_idx = 0;
        y_idx = 0;
    endfunction

    protected virtual function void validate_configuration_ready();
        if (!computation_params.ifmaps_cfg_shared)
            `sauria_fatal(message_id, "IFMAPS model used before configuration was shared")

    endfunction

    protected virtual function void configure_from_computation_params();
        set_incntlim(computation_params.incntlim);
        configure(computation_params.core_ifmaps_params,
                  computation_params.ifmaps_rows_active);
    endfunction

     /*-------------------------------------------------- */

endclass