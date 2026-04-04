class sauria_weights_feeder_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_weights_feeder_scbd)

    sauria_weights_feeder_seq_item weights_feeder_item;

    `uvm_analysis_imp_decl(_weights_feeder_info)
    uvm_analysis_imp_weights_feeder_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_info;

    `uvm_analysis_imp_decl (_weights_feeder_sramb_access_info)
    uvm_analysis_imp_weights_feeder_sramb_access_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_sramb_access_info;

    `uvm_analysis_imp_decl (_weights_feeder_arr_info)
    uvm_analysis_imp_weights_feeder_arr_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_arr_info;
    
    string message_id = "SAURIA_WEIGHTS_FEEDER_SCBD";
    
    sramb_addr_t               exp_next_sramb_addr;   
    weights_feeder_data_t      feeder_data[$];
    weights_feeder_data_t      feeder_data_inst;
    weights_feeder_data_t      popped_inst;

    arr_row_data_t             weights_cols_active;

    weights_params_t           weights_params;
    sauria_axi4_lite_data_t    w_idx,k_idx;
    
    sauria_axi4_lite_data_t    act_reps, wei_reps;
    sauria_axi4_lite_data_t    act_rep_idx, wei_rep_idx;

    int                        incntlim, comp_feeding_len;
    int                        idx_curr_comp, idx_next_comp;
    sauria_computation_params  computation_params;
    bit                        wei_feeding_not_done;
    bit                        overlapping_comps;
   
    function new(string name="sauria_weights_feeder_scbd", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_weights_feeder_info              = new("SAURIA_WEIGHTS_FEEDER_ANALYSIS_IMP", this);
        receive_weights_feeder_sramb_access_info = new("SAURIA_WEIGHTS_FEEDEER_SRAMB_ACCESS_INFO", this);
        receive_weights_feeder_arr_info          = new("SAURIA_WEIGHTS_FEEDER_ARR_INFO_ANALYSIS_IMP", this);
    
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.main_controller_cfg_shared);
        act_reps         = computation_params.act_reps;
        wei_reps         = computation_params.wei_reps;

        `sauria_info(message_id, $sformatf("Wei Reps: %0d Act_Reps: %0d", wei_reps, act_reps))

        incntlim         = computation_params.incntlim;
        comp_feeding_len = incntlim + sauria_pkg::X;

        wait(computation_params.weights_cfg_shared);
        weights_params   = computation_params.core_weights_params;
        weights_cols_active = computation_params.weights_cols_active;
    endtask
    
    function write_weights_feeder_info(sauria_weights_feeder_seq_item weights_feeder_info);
        weights_feeder_item = weights_feeder_info;

        if (weights_feeder_info.feeder_clear && weights_feeder_info.clearfifo) begin
            feeder_data.delete();
            idx_curr_comp       = 0;
            idx_next_comp       = 0;
            overlapping_comps   = 0;
            exp_next_sramb_addr = sramb_addr_t'(0);
            clear_counters();
        end
    endfunction

    function write_weights_feeder_sramb_access_info(sauria_weights_feeder_seq_item weights_feeder_sramb_access_info);
        feeder_data_inst.sramb_addr = weights_feeder_sramb_access_info.sramb_addr;
        feeder_data_inst.sramb_data = weights_feeder_sramb_access_info.sramb_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMB Access Addr: 0x%0h Data: 0x%0h Q_Size: %0d",
        feeder_data_inst.sramb_addr ,feeder_data_inst.sramb_data, feeder_data.size()))

        check_sramb_rd_addr();
        update_exp_sramb_rd_addr();
        feeder_data.push_back(feeder_data_inst);
        
        if (weights_feeder_sramb_access_info.til_done && 
            !(w_idx == srama_addr_t'(0) && k_idx == srama_addr_t'(0)))
            `sauria_error(message_id, $sformatf("Tile Done Condition And Counters Mismatch W_IDX: 0x%0h K_IDX: 0x%0h", w_idx, k_idx))
    
    endfunction 

    function write_weights_feeder_arr_info(sauria_weights_feeder_seq_item weights_feeder_arr_info);
        
        wei_feeding_not_done = (idx_curr_comp >= incntlim) && (idx_curr_comp < (comp_feeding_len - 1));

        if (weights_feeder_arr_info.start_feeding) begin
            overlapping_comps = wei_feeding_not_done;
            `sauria_info(message_id, $sformatf("Weight Feeding Started Overlapping_Comps: %0d Comp_Idx: %0d", overlapping_comps, idx_curr_comp))
        end
    
        if (feeder_data.size() > 0)begin
            update_feeder_data(weights_feeder_arr_info.b_arr);
            if ($countones(feeder_data[0].arr_byte_valid) == sauria_pkg::X) begin
                feeder_data[0].b_arr      = get_reversed_array_bus(feeder_data[0].b_arr);
                feeder_data[0].sramb_data = get_masked_inactive_cols_data(feeder_data[0].sramb_data);
                if ((feeder_data[0].sramb_data != feeder_data[0].b_arr) && (!weights_feeder_arr_info.fifo_empty))
                    `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMB Read Data Q_Size: %0d Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    feeder_data.size(), feeder_data[0].sramb_addr ,feeder_data[0].sramb_data, feeder_data[0].b_arr ))
                else 
                    `sauria_info(message_id, $sformatf("Feeder Output Matches SRAMB Read Data Q_Size: %0d Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    feeder_data.size(), feeder_data[0].sramb_addr ,feeder_data[0].sramb_data, feeder_data[0].b_arr ))
                

                popped_inst = feeder_data.pop_front(); 
            end
            
            if(!weights_feeder_arr_info.pop_en && !overlapping_comps) clear_arr_byte_valids();
            
        end

        update_comp_indeces();
    endfunction

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

     virtual function void check_sramb_rd_addr();
        if (exp_next_sramb_addr != feeder_data_inst.sramb_addr)
            `sauria_error(message_id, $sformatf("SRAMB_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",  
        exp_next_sramb_addr, feeder_data_inst.sramb_addr))
    endfunction

    virtual function void update_exp_sramb_rd_addr();
        update_counters();
        set_counter_based_exp_addr();
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
        arr_row_data_rev_t rev_weights_cols_active  = weights_cols_active;

        for(int col=0; col < sauria_pkg::X; col++)begin
            masked_col_data[col] = (rev_weights_cols_active[col] == 1'b1) ? b_arr[col] : 0;

            if (weights_cols_active[col] == 1'b1) `sauria_info(message_id, $sformatf("WEIGHTS_COLS_ACTIVE COL: %0d", col))
        end
        return masked_col_data;
    endfunction

    virtual function void set_counter_based_exp_addr();
        exp_next_sramb_addr = (w_idx + k_idx) / SRAMB_N;    
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

endclass

