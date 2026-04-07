class sauria_systolic_array_model extends uvm_object;

    `uvm_object_utils(sauria_systolic_array_model)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_MODEL";

    a_arr_data_t      a_arr_entries[$];	 // Activation operands
	b_arr_data_t      b_arr_entries[$];	 // Weight operands
	
    bit                                     psums_preload_en;
    bit                                     first_preload_context;
    int                                     context_count;
    int unsigned                            popped_psum_col_entry_count;

    int                                     cscan_idx;
    bit                                     cscan_done;
    bit                                     cscan_last_shift;
    bit                                     cs_last_shift;
   
    scan_chain_data_t                       psum_shift_reg[$];
    scan_chain_data_t                       shift_reg_clone[$];
    
    bit                                     rd_ptr, wr_ptr;
    scan_chain_data_t                       psum_scan_chain_out_a[$];
    scan_chain_data_t                       psum_scan_chain_out_b[$];
    scan_chain_data_t                       psum_col;

    arr_psum_reg_t                          pre_cswitch_arr_psum_reserve_reg;
    arr_psum_reg_t                          preload_psums_reg;
    arr_psum_reg_t                          mac_psum_reg;

    int                                     incntlim;
    int                                     comp_feeding_len;

    bit                                     arr_feeding_done;
    bit                                     overlapping_contexts;
    int                                     idx_curr_comp, idx_next_comp;

    ifmaps_feeder_row_data_t                ifmaps_feeder_data[sauria_pkg::Y];
    weights_feeder_col_data_t               weights_feeder_data[sauria_pkg::X];

    ifmaps_feeder_data_t       ifmaps_feeder_out_data[$];
    ifmaps_feeder_data_t       ifmaps_feeder_out_data_inst, ifmaps_feeder_out_data_entry;

    weights_feeder_data_t      weights_feeder_out_data[$];
    weights_feeder_data_t      weights_feeder_out_data_inst, weights_feeder_out_data_entry;

    a_arr_data_t               ifmaps_entry;
    b_arr_data_t               weights_entry;

    a_arr_data_t               popped_a_entry;
    b_arr_data_t               popped_b_entry;

    function new(string name="sauria_systolic_array_model");
        super.new(name);
    endfunction

    virtual function void reset();
        idx_curr_comp = 0;
        context_count = 0;
        rd_ptr        = 0;
        wr_ptr        = 0;
        clear_all_queues();
    endfunction

    virtual function void set_incntlim(int incntlim);
        this.incntlim = incntlim;
        comp_feeding_len = incntlim + sauria_pkg::X;
    endfunction

    virtual function void set_psums_preload_en(bit psums_preload_en);
        this.psums_preload_en = psums_preload_en;
    endfunction

    virtual function void add_scan_chain_in_data(scan_chain_data_t i_c_arr);
        if (cscan_idx == sauria_pkg::X - 1) begin
            cscan_last_shift = 1'b1;
        end
        else if (cscan_idx == sauria_pkg::X) begin
            cscan_last_shift = 1'b0;
            cscan_done      = 1'b1;
        end

        psum_shift_reg.push_back(i_c_arr);
        cscan_idx++;
    endfunction

    virtual function void update_context_count();
        context_count++;
    endfunction

    virtual function void update_popped_psums_col_entry_count();
        popped_psum_col_entry_count++;
    endfunction

    virtual function bit is_first_mac_elem_done();
        return (idx_curr_comp == incntlim);
    endfunction

    virtual function bit is_first_preload_context();
        return (context_count < 2) && psums_preload_en;
    endfunction

    virtual function void reset_cscan();
        cscan_idx  = 0;
        cscan_done = 1'b0;
    endfunction

    virtual function bit is_cscan_done();
        return cscan_done;
    endfunction

    virtual function bit is_cscan_last_shift();
        return cscan_last_shift;
    endfunction

    virtual function bit is_preload_en();
        return psums_preload_en;
    endfunction

    virtual function bit is_scan_chain_out_data_valid();
        return  (!cscan_last_shift && (!psums_preload_en || !is_first_preload_context()));
    endfunction

    virtual function bit is_scan_chain_fifo_empty();
        int q_size = rd_ptr ? psum_scan_chain_out_b.size() : psum_scan_chain_out_a.size();
        return (q_size == 0);
    endfunction

    virtual function scan_chain_data_t get_scan_chain_out_col();
        scan_chain_data_t scan_chain_out_col;
        
        case(rd_ptr)
            0: scan_chain_out_col = psum_scan_chain_out_a.pop_front();
            1: scan_chain_out_col = psum_scan_chain_out_b.pop_front();
        endcase

        update_popped_psums_col_entry_count();
        
        if (all_curr_ctx_psum_cols_popped()) begin
            `sauria_info(message_id, $sformatf("All Cols Popped Flipping RD PTR %0d", rd_ptr))
            flip_rd_ptr();
        end
        return scan_chain_out_col;
    endfunction

    virtual function int get_curr_scan_chain_out_col_idx();
        case(rd_ptr)
            0: return sauria_pkg::X  - psum_scan_chain_out_a.size();
            1: return sauria_pkg::X  - psum_scan_chain_out_b.size();
        endcase
    endfunction

    virtual function bit all_curr_ctx_psum_cols_popped();
        return (popped_psum_col_entry_count != 0) && ((popped_psum_col_entry_count % sauria_pkg::X) == 0);
    endfunction

    virtual function void flip_rd_ptr();
        rd_ptr = !rd_ptr;
    endfunction

    virtual function void flip_wr_ptr();
        wr_ptr = !wr_ptr;
    endfunction

    virtual function scan_chain_data_q_t get_psum_shift_reg_clone();
        shift_reg_clone = psum_shift_reg;
        psum_shift_reg.delete();
        return scan_chain_data_q_t'(shift_reg_clone);
    endfunction

    virtual function void set_pre_cswitch_arr_psum_reserve_reg(arr_psum_reg_t pre_cswitch_arr_psum_reserve_reg);
        this.pre_cswitch_arr_psum_reserve_reg = pre_cswitch_arr_psum_reserve_reg;
    endfunction

    virtual function arr_psum_reg_t get_pre_cswitch_arr_psums_reserve_reg();
        return pre_cswitch_arr_psum_reserve_reg;
    endfunction

    /***********COMPUTATION FUNCTIONS************************* */

    virtual function void start_context();
        overlapping_contexts = is_array_feeding_done();
        idx_next_comp = 0;
        `sauria_info(message_id, $sformatf("Started Feeding Overlapping Contexts: %0d", overlapping_contexts))
    endfunction

    virtual function void feed_context(a_arr_data_t a_arr,b_arr_data_t b_arr);

        `sauria_info (message_id, "Feeder Data Valid")
            
        if(is_ifmaps_feeding_in_progress())
            add_ifmaps_feeder_out_data(a_arr);
        
            
        if (is_weights_feeding_in_progress())
            add_weights_feeder_out_data(b_arr);
        
            
        if (is_context_in_progress())begin
            
            if (has_ifmaps_feeder_valid_entry())
                feed_valid_ifmaps_column();
            

            if (has_weights_feeder_valid_entry())
                feed_valid_weights_row();
            
            if(overlapping_contexts) update_next_context();
            update_current_context();
        end

    endfunction

    virtual function void compute_context();
        `sauria_info(message_id, $sformatf("IDX_NEXT_COMP: %0d", idx_next_comp))
                
        idx_curr_comp   = idx_next_comp;

        if (idx_next_comp == 0 )begin
            ifmaps_feeder_out_data.delete();
            weights_feeder_out_data.delete();
        end

        idx_next_comp   = 0;
        overlapping_contexts = 0;

        get_ifmaps_rows();
        get_weights_cols();
            
        if(psums_preload_en)
            preload_mac_psums();

        calculate_mac();
        clear_feeder_data();
        set_scan_chain_out_cols();
        
    endfunction

    virtual function void get_ifmaps_rows();
        for(int c=0; c < incntlim; c++)begin
            for(int row=0; row < sauria_pkg::Y; row++)begin
                ifmaps_feeder_data[row].ifmaps_data.push_back(a_arr_entries[0][row]);

                if(row == 0 )
                    `sauria_info(message_id, $sformatf("IFMAPS_ROW: %0d_DATA: 0x%0h C: %0d",  row, a_arr_entries[0][row], c))

            end
            popped_a_entry = a_arr_entries.pop_front();
        end

    endfunction

    virtual function void get_weights_cols();
        `sauria_info(message_id, $sformatf("Getting Weights C: %0d INCNTLIM: %0d", b_arr_entries.size(), incntlim))
        for(int c=0; c < incntlim; c++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                weights_feeder_data[col].weights_data.push_back(b_arr_entries[0][col]);

                if(col == 0)
                    `sauria_info(message_id, $sformatf("WEIGHTS_COL_0_DATA: 0x%0h C: %0d", b_arr_entries[0][col], c))
            end
            popped_b_entry = b_arr_entries.pop_front();
        end
    endfunction

     virtual function void calculate_mac();
        shortreal fp_ifmaps_data;
        shortreal fp_weights_data;
        shortreal fp_accum;

        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                for(int c=0; c < incntlim; c++)begin
                    if (FP_ARITHMETIC) begin
                        fp_ifmaps_data = fp16_to_shortreal(ifmaps_feeder_data[row].ifmaps_data[c]);
                        fp_weights_data = fp16_to_shortreal(weights_feeder_data[col].weights_data[c]);
                        fp_accum += fp_ifmaps_data * fp_weights_data;

                        if (c == (incntlim - 1)) begin
                            mac_psum_reg[row][col] = shortreal_to_fp16(fp_accum);
                            fp_accum = 0.0;
                        end
                        
                    end
                    else
                        mac_psum_reg[row][col] += ifmaps_feeder_data[row].ifmaps_data[c] * weights_feeder_data[col].weights_data[c];
                end
            `sauria_info(message_id, $sformatf("Partial Sum Row: %0d Col: %0d Accum_Val: 0x%0h", row, col, mac_psum_reg[row][col]))
            end
        end
    endfunction

    virtual function void set_scan_chain_out_cols();

        for(int col=0; col < sauria_pkg::X; col++)begin
            for(int row=0; row < sauria_pkg::Y; row++)begin
                psum_col[row] = mac_psum_reg[row][col];

                if (col == 0)
                    `sauria_info(message_id, $sformatf("Col0 Row: %0d PSUM_VAL: 0x%0h", row, psum_col[row]))

                mac_psum_reg[row][col] = 0;
            end
            
            case(wr_ptr)
                0: psum_scan_chain_out_a.push_back(psum_col);
                1: psum_scan_chain_out_b.push_back(psum_col);
            endcase
        end

        flip_wr_ptr();        
    
    endfunction

    virtual function void update_ifmaps_feeder_data(a_arr_data_t a_arr);
        int last_valid_queue_elem = (ifmaps_feeder_out_data.size() < sauria_pkg::Y) ? ifmaps_feeder_out_data.size() : sauria_pkg::Y;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            
            if ((i == sauria_pkg::Y - 1 -  (idx_curr_comp - incntlim)) && (idx_curr_comp >= incntlim) && (!overlapping_contexts))
                break;

            for(int row=0; row < sauria_pkg::Y; row++)begin
                //Find first invalid element
                if(!ifmaps_feeder_out_data[i].arr_byte_valid[row]) begin
                    ifmaps_feeder_out_data[i].arr_byte_valid[row] = 1'b1; //Set To Valid
                    ifmaps_feeder_out_data[i].a_arr[row]          = a_arr[row];
                    
                    if (i == 0) last_valid_queue_elem  = row + 1;
                    `sauria_info(message_id, $sformatf("Valid elem_idx: %0d a_arr_row[%0d]: 0x%0h Entry_Val: 0x%0h",
                    i, row, a_arr[row], a_arr))
                    break;    
                end
            end
            
        end
    endfunction

    virtual function void update_weights_feeder_data(b_arr_data_t b_arr);
        int last_valid_queue_elem = (weights_feeder_out_data.size() < sauria_pkg::X) ? weights_feeder_out_data.size() : sauria_pkg::X;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            
            if ((i == sauria_pkg::X - 1 -  (idx_curr_comp - incntlim)) && (idx_curr_comp >= incntlim) && (!overlapping_contexts))
                break;

            for(int col=0; col < sauria_pkg::X; col++)begin

                //Find first invalid element
                if(!weights_feeder_out_data[i].arr_byte_valid[col]) begin
                    weights_feeder_out_data[i].arr_byte_valid[col] = 1'b1; //Set To Valid
                    weights_feeder_out_data[i].b_arr[col]          = b_arr[col];
                    
                    if ((i == 0)  && (col < last_valid_queue_elem)) 
                        last_valid_queue_elem  = col + 1;
                    else if (overlapping_contexts)
                        last_valid_queue_elem = i + col + 1;

                    `sauria_info(message_id, $sformatf("Valid elem_idx: %0d b_arr_col[%0d]: 0x%0h Entry_Val: 0x%0h Last_Valid_Elem: %0d",
                    i, col, b_arr[col], b_arr, last_valid_queue_elem))
                    break;    
                end
            end
            
        end
    endfunction

    virtual function void save_preload_values(ref arr_psum_reg_t arr_psum_reserve_reg);
        for(int col=0; col < sauria_pkg::X; col++)begin
            for(int row=0; row < sauria_pkg::Y; row++)
                preload_psums_reg[row][col] = arr_psum_reserve_reg[row][col];
        end
    endfunction

    virtual function void preload_mac_psums();
        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)
                mac_psum_reg[row][col] = preload_psums_reg[row][col];
            
        end
    endfunction

    virtual function void clear_all_queues();
        ifmaps_feeder_out_data.delete();
        weights_feeder_out_data.delete();
        a_arr_entries.delete();
        b_arr_entries.delete();
        psum_scan_chain_out_a.delete();
        psum_scan_chain_out_b.delete();
        clear_feeder_data();
    endfunction

    virtual function void clear_feeder_data();
        clear_ifmaps_feeder_data();
        clear_weights_feeder_data();
    endfunction
    
    virtual function void clear_ifmaps_feeder_data();
        for(int row=0; row < sauria_pkg::Y; row++)begin
            ifmaps_feeder_data[row].ifmaps_data.delete();
        end
    endfunction

    virtual function void clear_weights_feeder_data();
        for(int col=0; col < sauria_pkg::X; col++)begin
            weights_feeder_data[col].weights_data.delete();
        end
    endfunction

    virtual function bit is_array_feeding_done();
        return (idx_curr_comp >= incntlim) && (idx_curr_comp <= comp_feeding_len);
    endfunction

    virtual function bit is_context_MAC_done();
        return idx_curr_comp == (comp_feeding_len - 1);
    endfunction

    virtual function bit is_context_in_progress();
        return idx_curr_comp < comp_feeding_len;
    endfunction

    virtual function bit is_ifmaps_feeding_in_progress();
        return (idx_curr_comp < (incntlim + sauria_pkg::Y)) || (overlapping_contexts);
    endfunction

    virtual function bit is_weights_feeding_in_progress();
        return (idx_curr_comp < (incntlim + sauria_pkg::X)) || (overlapping_contexts);
    endfunction

    virtual function bit has_ifmaps_feeder_valid_entry();
        return $countones(ifmaps_feeder_out_data[0].arr_byte_valid) == sauria_pkg::Y;
    endfunction

    virtual function bit has_weights_feeder_valid_entry();
        return $countones(weights_feeder_out_data[0].arr_byte_valid) == sauria_pkg::X;
    endfunction

    virtual function void add_ifmaps_feeder_out_data(a_arr_data_t a_arr);
        `sauria_info(message_id, "Adding IFMAPS Feed  Out Data")
        ifmaps_feeder_out_data.push_back(ifmaps_feeder_out_data_inst);
        update_ifmaps_feeder_data(a_arr);
    endfunction

    virtual function void add_weights_feeder_out_data(b_arr_data_t b_arr);
        `sauria_info(message_id, "Adding WEIGHTS Feed  Out Data")
        weights_feeder_out_data.push_back(weights_feeder_out_data_inst);
        update_weights_feeder_data(b_arr);
    endfunction

    virtual function void feed_valid_ifmaps_column();
        ifmaps_feeder_out_data_entry = ifmaps_feeder_out_data.pop_front();
        a_arr_entries.push_back(ifmaps_feeder_out_data_entry.a_arr);  
        `sauria_info(message_id, $sformatf("Add Valid IFMAPS Column 0x%0h", ifmaps_feeder_out_data_entry.a_arr))  
    endfunction

    virtual function void feed_valid_weights_row();
        weights_feeder_out_data_entry = weights_feeder_out_data.pop_front();
        `sauria_info(message_id, $sformatf("B_ARR_ENTRY_READY FEEDER_OUT_DATA_SIZE: %0d CURR_Q_SIZE: %0d Ones: %0d Val: 0x%0h IDX_Curr_Comp: %0d", 
        weights_feeder_out_data.size() + 1, b_arr_entries.size(), $countones(weights_feeder_out_data_entry.b_arr), weights_feeder_out_data_entry.b_arr, idx_curr_comp))
        b_arr_entries.push_back(weights_feeder_out_data_entry.b_arr);    
    endfunction

    virtual function void update_current_context();
        idx_curr_comp++;
    endfunction

    virtual function void update_next_context();
        idx_next_comp++;
    endfunction

    virtual function shortreal fp16_to_shortreal (sauria_fp_elem_data_t fp_elem_data);
        bit [31:0] fp32;
        bit [4:0]  exp16;
        bit [9:0]  man16;
        bit        sign;

        sign  = fp_elem_data[15];
        exp16 = fp_elem_data[14:10];
        man16 = fp_elem_data[9:0];

        if (exp16 == 0) begin
            // Case: Zero or Subnormal
            // For a simple model, we can treat subnormals as zero
            fp32 = {sign, 31'b0};
        end else if (exp16 == 5'h1F) begin
            // Case: Infinity or NaN
            fp32 = {sign, 8'hFF, 23'b0}; 
        end else begin
            // Case: Normal numbers
            // Re-bias: New Exp = Exp - 15 + 127 = Exp + 112
            fp32 = {sign, (8'(exp16) + 8'd112), man16, 13'b0};
        end

        return $bitstoshortreal(fp32);
    endfunction

    virtual function sauria_fp_elem_data_t shortreal_to_fp16(shortreal fp_elem_data);
        bit [31:0] f32;
        bit [15:0] f16;
        bit [7:0]  exp32;
        bit [22:0] man32;
        bit        sign;
        int        new_exp;

        f32   = $shortrealtobits(fp_elem_data);
        sign  = f32[31];
        exp32 = f32[30:23];
        man32 = f32[22:0];

        // 1. Handle Zero
        if (exp32 == 0) return {sign, 15'b0};

        // 2. Handle Infinity / NaN
        if (exp32 == 8'hFF) return {sign, 5'h1F, 10'h0};

        // 3. Calculate New Exponent (Re-bias: Exp - 127 + 15 = Exp - 112)
        new_exp = int'(exp32) - 112;

        // 4. Check for Overflow/Underflow
        if (new_exp >= 31) begin
            // Overflow to Infinity
            return {sign, 5'h1F, 10'h0};
        end else if (new_exp <= 0) begin
            // Underflow to Zero (or subnormal, but zero is safer for simple models)
            return {sign, 15'b0};
        end else begin
            // Normal Number: Pack Sign, New Exponent, and top 10 bits of Mantissa
            return {sign, 5'(new_exp), man32[22:13]};
        end
    endfunction
     
endclass