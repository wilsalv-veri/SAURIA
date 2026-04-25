class sauria_weights_feeder_model extends sauria_feeder_base_model;

    `uvm_object_utils(sauria_weights_feeder_model)

    sramb_addr_t               exp_next_sramb_addr;   
    weights_feeder_data_t      feeder_data[$];
    weights_feeder_data_t      feeder_data_inst;

    arr_row_data_t             weights_cols_active;
    arr_row_data_t             weights_gwoff_cols_active;

    weights_params_t           weights_params;
    sauria_axi4_lite_data_t    w_idx,k_idx;
    
    sauria_axi4_lite_data_t    act_reps, wei_reps;
    sauria_axi4_lite_data_t    act_rep_idx, wei_rep_idx;

    bit                        wei_feeding_not_done;
            
   
    function new(string name="sauria_weights_feeder_model");
        super.new(name);
        set_message_id("SAURIA_WEIGHTS_FEEDER_MODEL");
    endfunction

    virtual function void configure(weights_params_t weights_params, arr_row_data_t weights_cols_active);
        this.weights_params            = weights_params;
        this.weights_gwoff_cols_active = get_bitmask(weights_params.tile_params.weights_k_step);
        this.weights_cols_active       = weights_cols_active;
        is_configured                  = 1'b1;
    endfunction

    virtual function void set_incntlim(sauria_axi4_lite_data_t incntlim);
        set_incntlim_and_comp_feeding_len(incntlim, sauria_pkg::X);
    endfunction

    virtual function void set_reps(sauria_axi4_lite_data_t act_reps, sauria_axi4_lite_data_t wei_reps);
        this.act_reps = act_reps;
        this.wei_reps = wei_reps;
        `sauria_info(message_id, $sformatf("Wei Reps: %0d Act_Reps: %0d", wei_reps, act_reps))
    endfunction

    virtual function void reset_model();
        feeder_data.delete();
        reset_overlap_tracking();
        exp_next_sramb_addr = sramb_addr_t'(0);
        clear_counters();
    endfunction

    virtual function weights_feeder_sramb_access_result_t observe_sramb_access(weights_feeder_data_t weights_feeder_data,
                                                                                bit                   til_done);
        weights_feeder_sramb_access_result_t result = '{default:'0};

        ensure_configured();

        if (til_done) begin
            result.w_idx = w_idx;
            result.k_idx = k_idx;
            result.tile_done_counter_mismatch = !are_tile_done_counters_cleared();
        end

        result.exp_sramb_addr = exp_next_sramb_addr;
        result.addr_mismatch  = (result.exp_sramb_addr != weights_feeder_data.sramb_addr);

        add_weights_sram_access(weights_feeder_data);

        return result;
    endfunction

    virtual function weights_feeder_arr_feed_result_t observe_arr_feed(b_arr_data_t b_arr,
                                                                        bit          start_feeding,
                                                                        bit          pop_en,
                                                                        bit          fifo_empty);
        weights_feeder_arr_feed_result_t result = '{default:'0};

        ensure_configured();

        if (start_feeding)
            set_overlapping_comp();

        add_weights_systolic_feed_data(b_arr);

        if (has_valid_entry() && !fifo_empty)
            result = get_valid_entry();

        if(!(pop_en || is_overlapping_comps()))
            clear_arr_byte_valids();

        update_comp_indeces();
        return result;
    endfunction

    virtual function void add_weights_sram_access(weights_feeder_data_t weights_feeder_data);   
        feeder_data.push_back(weights_feeder_data);
        update_exp_sramb_rd_addr();
    endfunction

    virtual function void add_weights_systolic_feed_data(b_arr_data_t b_arr);
        if (feeder_data.size() > 0)begin
            update_feeder_data(b_arr);        
        end
        else `sauria_error(message_id, "WEIGHTS Feeder Fed Data Without Reading From SRAMB")

    endfunction
    
    /*---------------------Address Helper Function------------------- */
    virtual function void set_counter_based_exp_addr();
        exp_next_sramb_addr = (w_idx + k_idx) / SRAMB_N;    
    endfunction

    virtual function void update_exp_sramb_rd_addr();
        update_counters();
        set_counter_based_exp_addr();
    endfunction
    
    virtual function void update_counters();
        if ((w_idx + weights_params.tile_params.weights_w_step) 
            < weights_params.tile_params.weights_C)begin
            w_idx += weights_params.tile_params.weights_w_step;
        end
        else if (wei_rep_idx < wei_reps - 1)begin
                wei_rep_idx++;
                w_idx  = 0;
        end
        else if ((k_idx + weights_params.tile_params.weights_k_step) 
            < weights_params.tile_params.weights_K)begin
            w_idx       = 0;
            wei_rep_idx = 0;
            k_idx      += weights_params.tile_params.weights_k_step;
        end
        else begin
            wei_rep_idx = 0;
            w_idx       = 0;
            k_idx       = 0;
        end

        `sauria_info(message_id, $sformatf("Updated WEIGHT Counters W:%0d K:%0d", w_idx, k_idx))
    
    endfunction

    virtual function void clear_counters();
        wei_rep_idx = 0;
        w_idx       = 0;
        k_idx       = 0;
    endfunction

    virtual function bit are_tile_done_counters_cleared();
        return (w_idx == sramb_addr_t'(0)) &&
               (k_idx == sramb_addr_t'(0));
    endfunction

    /*------------------------------------------------------------- */
    
    /*---------------------Data Helper Function --------------------*/
   
    virtual function void update_feeder_data(b_arr_data_t b_arr);
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::X) ? feeder_data.size() : sauria_pkg::X;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            
            if ((i == sauria_pkg::X - 1 -  (idx_curr_comp - incntlim)) && (idx_curr_comp >= incntlim)  && (idx_curr_comp != (comp_feeding_len - 1)) && (!overlapping_comps))
                break;

            for(int col=0; col < sauria_pkg::X; col++)begin

                //Find first invalid element
                if(!feeder_data[i].arr_byte_valid[col]) begin
                    feeder_data[i].arr_byte_valid[col] = 1'b1; //Set To Valid
                    feeder_data[i].b_arr[col]          = b_arr[col];
                    
                    if ((i == 0) && (col < last_valid_queue_elem)) begin
                        last_valid_queue_elem  = col + 1;
                    end
                    else if ((overlapping_comps) && (col == 0)) begin
                           
                        `sauria_info(message_id, $sformatf("Overlapping Comps Found Idx: %0d Col: %0d Last_Valid_Elem_Before: %0d Last_Valid_Elem_After: %0d", 
                        i, col, last_valid_queue_elem, i))

                        last_valid_queue_elem = i;
                    end

                    `sauria_info(message_id, $sformatf("Elem_Idx: %0d Valid b_arr_col[%0d]: 0x%0h Entry_Val: 0x%0h",
                    i, col, b_arr[col], b_arr))
                    break;    
                end
            end
            
        end

    endfunction

    virtual function void update_comp_indeces();
        idx_curr_comp = ((overlapping_comps == 1'b1) && (idx_curr_comp == (comp_feeding_len - 2))) ? idx_next_comp + 1 : (idx_curr_comp + 1) % comp_feeding_len;
        idx_next_comp = (overlapping_comps == 1'b1) ? idx_next_comp + 1 : 0;

        if (idx_curr_comp == idx_next_comp) overlapping_comps = 1'b0;
    endfunction

    virtual function void clear_arr_byte_valids();

        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::X) ? feeder_data.size() : sauria_pkg::X;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int col=0; col < sauria_pkg::X; col++)begin
                feeder_data[i].arr_byte_valid[col] = 1'b0;
            end
        end

    endfunction

    virtual function b_arr_data_t get_reversed_array_bus(b_arr_data_t b_arr);
        b_arr_data_t reversed_bus;
        for(int row=0; row < sauria_pkg::X; row++)begin
            reversed_bus[row] = b_arr[sauria_pkg::X - 1 - row];
        end
        return reversed_bus;
    endfunction

    virtual function b_arr_data_t get_masked_inactive_cols_data(b_arr_data_t b_arr);
        b_arr_data_t       masked_col_data;
        arr_row_data_rev_t rev_weights_cols_active  = weights_cols_active & weights_gwoff_cols_active;

        for(int col=0; col < sauria_pkg::X; col++)begin
            masked_col_data[col] = (rev_weights_cols_active[col] == 1'b1) ? b_arr[col] : 0;

            if (weights_cols_active[col] == 1'b1) `sauria_info(message_id, $sformatf("WEIGHTS_COLS_ACTIVE COL: %0d", col))
        end
        return masked_col_data;
    endfunction

    virtual function void set_overlapping_comp();
        wei_feeding_not_done = (idx_curr_comp >= incntlim) && (idx_curr_comp < (comp_feeding_len - 1));
        overlapping_comps    = wei_feeding_not_done;
        `sauria_info(message_id, $sformatf("Weight Feeding Started Overlapping_Comps: %0d Comp_Idx: %0d", overlapping_comps, idx_curr_comp))
    endfunction

    virtual function bit is_overlapping_comps();
        return overlapping_comps;
    endfunction

    virtual function bit has_valid_entry();
        return (feeder_data.size() > 0) &&
               ($countones(feeder_data[0].arr_byte_valid) == sauria_pkg::X);
    endfunction

    virtual function weights_feeder_arr_feed_result_t get_valid_entry();
        weights_feeder_arr_feed_result_t result = '{default:'0};

        feeder_data_inst       = feeder_data.pop_front();
        result.valid_entry     = 1'b1;
        result.sramb_addr      = feeder_data_inst.sramb_addr;
        result.exp_sramb_data  = get_masked_inactive_cols_data(feeder_data_inst.sramb_data);
        result.exp_b_arr_data  = get_reversed_array_bus(feeder_data_inst.b_arr);

        `sauria_info(message_id, $sformatf("Getting B_ARR_Data: 0x%0h Reversed: 0x%0h", feeder_data_inst.b_arr, result.exp_b_arr_data))

        return result;
    endfunction

    virtual function arr_row_data_t get_bitmask(sauria_axi4_lite_data_t k_step);
        //bit set_mask = 1'b1;
        //arr_row_data_t set_mask = {{sauria_pkg::X{set_mask}}}
        arr_row_data_t set_mask = {1'b1, {($bits(arr_row_data_t) - 1 ){1'b0}}};
        arr_row_data_t bitmask;

        for(int i=0; i < k_step; i++)begin
            bitmask |= set_mask; //1'b1;
            
            if (i != (k_step - 1))
                bitmask >>= 1;
        end

        return bitmask;
    endfunction

    protected virtual function void validate_configuration_ready();
        if (!computation_params.main_controller_cfg_shared)
            `sauria_fatal(message_id, "Weights model used before main controller configuration was shared")

        if (!computation_params.weights_cfg_shared)
            `sauria_fatal(message_id, "Weights model used before weights configuration was shared")

    endfunction

    protected virtual function void configure_from_computation_params();
        set_incntlim(computation_params.incntlim);
        set_reps(computation_params.act_reps,
                 computation_params.wei_reps);
        configure(computation_params.core_weights_params,
                  computation_params.weights_cols_active);
    endfunction

endclass