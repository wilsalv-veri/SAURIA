class sauria_weights_feeder_model extends uvm_object;

    `uvm_object_utils(sauria_weights_feeder_model)

    string message_id = "SAURIA_WEIGHTS_FEEDER_MODEL";

    sramb_addr_t               exp_next_sramb_addr;   
    weights_feeder_data_t      feeder_data[$];
    weights_feeder_data_t      feeder_data_inst;
    weights_feeder_data_t      popped_inst;

    arr_row_data_t             weights_cols_active;
    arr_row_data_t             weights_gwoff_cols_active;

    weights_params_t           weights_params;
    sauria_axi4_lite_data_t    w_idx,k_idx;
    
    sauria_axi4_lite_data_t    act_reps, wei_reps;
    sauria_axi4_lite_data_t    act_rep_idx, wei_rep_idx;

    sauria_axi4_lite_data_t    incntlim, comp_feeding_len;
    sauria_axi4_lite_data_t    idx_curr_comp, idx_next_comp;
    
    bit                        wei_feeding_not_done;
    bit                        overlapping_comps;

    bit                        valid_entry_sramb_addr_accessed;
    bit                        valid_entry_sramb_data_accessed;
    bit                        valid_entry_b_arr_data_accessed;
            
   
    function new(string name="sauria_weights_feeder_model");
        super.new(name);
    endfunction

    virtual function void configure(weights_params_t weights_params, arr_row_data_t weights_cols_active);
        this.weights_params            = weights_params;
        this.weights_gwoff_cols_active = get_bitmask(weights_params.tile_params.weights_k_step);
        this.weights_cols_active       = weights_cols_active;
    endfunction

    virtual function void set_incntlim(sauria_axi4_lite_data_t incntlim);
        this.incntlim = incntlim;
        comp_feeding_len  = incntlim + sauria_pkg::X;
    endfunction

    virtual function void set_reps(sauria_axi4_lite_data_t act_reps, sauria_axi4_lite_data_t wei_reps);
        this.act_reps = act_reps;
        this.wei_reps = wei_reps;
        `sauria_info(message_id, $sformatf("Wei Reps: %0d Act_Reps: %0d", wei_reps, act_reps))
    endfunction

    virtual function void reset_model();
        feeder_data.delete();
        idx_curr_comp       = 0;
        idx_next_comp       = 0;
        overlapping_comps   = 0;
        exp_next_sramb_addr = sramb_addr_t'(0);
        clear_counters();
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

    virtual function sramb_addr_t get_next_exp_sramb_rd_addr();
        return exp_next_sramb_addr;
    endfunction

    virtual function sauria_axi4_lite_data_t get_w_idx();
        return w_idx;
    endfunction

    virtual function sauria_axi4_lite_data_t get_k_idx();
        return k_idx;
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
        return $countones(feeder_data[0].arr_byte_valid) == sauria_pkg::X;
    endfunction

    virtual function sramb_addr_t get_valid_entry_sramb_addr();
        valid_entry_sramb_addr_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        pop_valid_entry();
        return feeder_data_inst.sramb_addr;
    endfunction

    virtual function sramb_data_t get_valid_sramb_data();
        valid_entry_sramb_data_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        pop_valid_entry();
        return get_masked_inactive_cols_data(feeder_data_inst.sramb_data);
    endfunction
 
    virtual function b_arr_data_t get_valid_b_arr_data();
        valid_entry_b_arr_data_accessed = 1'b1;
        feeder_data_inst = feeder_data[0];
        `sauria_info(message_id, $sformatf("Getting B_ARR_Data: 0x%0h Reversed: 0x%0h", feeder_data_inst.b_arr, get_reversed_array_bus(feeder_data_inst.b_arr)))
        pop_valid_entry();
        return get_reversed_array_bus(feeder_data_inst.b_arr);
    endfunction

    virtual function void pop_valid_entry();
        if (valid_entry_sramb_addr_accessed &&
            valid_entry_sramb_data_accessed &&
            valid_entry_b_arr_data_accessed) begin

            valid_entry_sramb_addr_accessed = 1'b0;
            valid_entry_sramb_data_accessed = 1'b0;
            valid_entry_b_arr_data_accessed = 1'b0;
            popped_inst = feeder_data.pop_front();

        end
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

endclass