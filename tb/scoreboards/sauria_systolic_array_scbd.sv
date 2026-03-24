class sauria_systolic_array_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_systolic_array_scbd)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_SCBD";

    `uvm_analysis_imp_decl (_systolic_array_info)
    uvm_analysis_imp_systolic_array_info #(sauria_systolic_array_seq_item, sauria_systolic_array_scbd)                   receive_systolic_array_info;

    sauria_systolic_array_seq_item          systolic_array_item;
    
    a_arr_data_t      a_arr_entries[$];	 // Activation operands
	b_arr_data_t      b_arr_entries[$];	 // Weight operands
	
    bit                                     psums_preload_en;
    bit                                     first_preload_context;
    int                                     context_count;

    int                                     cscan_idx;
    bit                                     cscan_done;
    bit                                     cscan_last_shift;
    bit                                     cs_last_shift;
   
    scan_chain_data_t                       shift_reg_copy[$];
    
    bit                                     rd_ptr, wr_ptr;
    scan_chain_data_t                       psum_scan_chain_out_a[$];
    scan_chain_data_t                       psum_scan_chain_out_b[$];
    scan_chain_data_t                       psum_col;

    arr_psum_reg_t                          pre_cswitch_arr_psum_reserve_reg;
    arr_psum_reg_t                          preload_psums_reg;
    arr_psum_reg_t                          mac_psum_reg;

    sauria_computation_params               computation_params;
    int                                     incntlim;
    int                                     comp_feeding_len;

    bit                                     arr_feeding_done;
    bit                                     count_next_comp;
    int                                     idx_curr_comp, idx_next_comp;

    ifmaps_feeder_row_data_t                ifmaps_feeder_data[sauria_pkg::Y];
    weights_feeder_col_data_t               weights_feeder_data[sauria_pkg::X];

    ifmaps_feeder_data_t       ifmaps_feeder_out_data[$];
    ifmaps_feeder_data_t       ifmaps_feeder_out_data_inst, ifmaps_feeder_out_data_entry;

    weights_feeder_data_t      weights_feeder_out_data[$];
    weights_feeder_data_t      weights_feeder_out_data_inst, weights_feeder_out_data_entry;

    a_arr_data_t               ifmaps_entry;
    b_arr_data_t               weights_entry;

    function new(string name="sauria_systolic_array_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_systolic_array_info          = new("SAURIA_SYSTOLIC_ARRAY_IMP", this);
        
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.main_controller_cfg_shared);
        incntlim         = computation_params.incntlim;

        wait(computation_params.psums_mgr_cfg_shared)
        psums_preload_en  = computation_params.psums_preload_en;
        comp_feeding_len = incntlim + sauria_pkg::X;
    endtask

    function write_systolic_array_info(sauria_systolic_array_seq_item systolic_array_info);
        systolic_array_item = systolic_array_info;
        
        if (systolic_array_item.reg_clear)begin
            idx_curr_comp = 0;
            context_count = 0;
            rd_ptr        = 0;
            wr_ptr        = 0;
            clear_all_queues();
        end
        else begin
            //Normal Operation
            if (systolic_array_item.scan_cswitch_valid)begin
                check_scan_chain();
                check_context_switch();
            end
            check_mac();
        end

        first_preload_context = (context_count < 2) && psums_preload_en;
    endfunction

    virtual function void check_scan_chain();
        if (systolic_array_item.cscan_en | cscan_last_shift) begin
            if (!cscan_last_shift && (!psums_preload_en || !first_preload_context)) begin
                check_scan_chain_out_data();
            end
            add_scan_chain_in_data();
        end
        else if (cscan_done)begin
            save_preload_values();
            check_array_psum_reg();
            cscan_idx  = 0;
            cscan_done = 1'b0;
        end
    endfunction

    virtual function void check_context_switch();
    
        if ((systolic_array_item.cswitch_arr != arr_row_data_t'(0)) || (systolic_array_item.cswitch_done_count != 0)) begin
            
            if (systolic_array_item.cswitch_arr == CS_FIRST_IDX) begin
                pre_cswitch_arr_psum_reserve_reg = systolic_array_item.pre_cswitch_arr_psum_reserve_reg;
            end
            check_accum_psum_reserve_swap();
        end
    endfunction

    virtual function void check_mac();

        arr_feeding_done = (idx_curr_comp >= incntlim) && (idx_curr_comp <= comp_feeding_len);

        if (idx_curr_comp == incntlim)
            context_count++;
        
        if (systolic_array_item.act_start_feeding || systolic_array_item.wei_start_feeding)begin
            count_next_comp = arr_feeding_done;
            idx_next_comp = 0;
            `sauria_info(message_id, $sformatf("Started Feeding Count_Next_Comp: %0d", count_next_comp))
        end

        if (idx_curr_comp == (comp_feeding_len - 1))begin
            `sauria_info(message_id, $sformatf("IDX_NEXT_COMP: %0d", idx_next_comp))
                
            idx_curr_comp   = idx_next_comp;

            if (idx_next_comp == 0 )begin
                ifmaps_feeder_out_data.delete();
                weights_feeder_out_data.delete();
            end

            idx_next_comp   = 0;
            count_next_comp = 0;

            get_ifmaps_rows();
            get_weights_cols();
            
            if(psums_preload_en)
                preload_mac_psums();

            calculate_mac();
            clear_feeder_data();
            set_scan_chain_out_cols();
            
        end

        if (systolic_array_item.act_data_valid || systolic_array_item.wei_data_valid)begin
            
            `sauria_info (message_id, "Feeder Data Valid")
            
            if((idx_curr_comp < (incntlim + sauria_pkg::Y)) || (count_next_comp))begin
                ifmaps_feeder_out_data.push_back(ifmaps_feeder_out_data_inst);
                update_ifmaps_feeder_data(systolic_array_item.a_arr);
            end
            
            weights_feeder_out_data.push_back(weights_feeder_out_data_inst);
            update_weights_feeder_data(systolic_array_item.b_arr);
            
            if (idx_curr_comp < comp_feeding_len)begin
            
                if ($countones(ifmaps_feeder_out_data[0].arr_byte_valid) == sauria_pkg::Y) begin
                    ifmaps_feeder_out_data_entry = ifmaps_feeder_out_data.pop_front();
                    a_arr_entries.push_back(ifmaps_feeder_out_data_entry.a_arr);
                end

                if ($countones(weights_feeder_out_data[0].arr_byte_valid) == sauria_pkg::X) begin
                    weights_feeder_out_data_entry = weights_feeder_out_data.pop_front();
                    `sauria_info(message_id, $sformatf("B_ARR_ENTRY_READY FEEDER_OUT_DATA_SIZE: %0d CURR_Q_SIZE: %0d Ones: %0d Val: 0x%0h IDX_Curr_Comp: %0d", 
                    weights_feeder_out_data.size() + 1, b_arr_entries.size(), $countones(weights_feeder_out_data_entry.b_arr), weights_feeder_out_data_entry.b_arr, idx_curr_comp))
                    b_arr_entries.push_back(weights_feeder_out_data_entry.b_arr);
                end

                if(count_next_comp) idx_next_comp++;
                idx_curr_comp++;
            end
        end

    endfunction

    virtual function void add_scan_chain_in_data();
        if (cscan_idx == sauria_pkg::X - 1) begin
            cscan_last_shift = 1'b1;
        end
        else if (cscan_idx == sauria_pkg::X) begin
            cscan_last_shift = 1'b0;
            cscan_done      = 1'b1;
        end

        shift_reg_copy.push_back(systolic_array_item.i_c_arr);
        cscan_idx++;
    endfunction

    virtual function void check_array_psum_reg();
        scan_chain_data_t col_psum_data;
            
        for(int col=0; col < shift_reg_copy.size(); col++)begin
            col_psum_data = shift_reg_copy[col];

            for(int row=0; row < sauria_pkg::Y; row++)begin
                if (col_psum_data[row] != systolic_array_item.arr_psum_reserve_reg[row][col])
                    `sauria_error(message_id, $sformatf("Array PSUM Reserve Register Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h", 
                row, col, col_psum_data[row], systolic_array_item.arr_psum_reserve_reg[row][col]))
            end
        end
        shift_reg_copy.delete();
    endfunction

    virtual function void check_accum_psum_reserve_swap();
        int cswitch_arr_en_idx = get_cswitch_en_idx();
        int cswitch_done_count = systolic_array_item.cswitch_done_count;
        int cswitch_idx = (cswitch_done_count > 0) ? sauria_pkg::X - 1 + cswitch_done_count : cswitch_arr_en_idx;

        `sauria_info(message_id, $sformatf("CSWITCH_ARR_EN_IDX: 0x%0h CSWITH_ARR_VAL: 0x%0h", cswitch_arr_en_idx, systolic_array_item.cswitch_arr))

        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                if ((row + col) == cswitch_idx) begin
                  
                    if (pre_cswitch_arr_psum_reserve_reg[row][col] != systolic_array_item.arr_psum_accum_in[row][col])
                        `sauria_error(message_id, $sformatf("Accumulator Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h",
                        row, col, pre_cswitch_arr_psum_reserve_reg[row][col], systolic_array_item.arr_psum_accum_in[row][col]))
                
                    if (systolic_array_item.arr_psum_accum_out[row][col] != systolic_array_item.arr_psum_reserve_reg[row][col])
                        `sauria_error(message_id, $sformatf("PSUM Reserve Reg Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h",
                        row, col, systolic_array_item.arr_psum_accum_out[row][col], systolic_array_item.arr_psum_reserve_reg[row][col]))
                      
                end
            end
        end

    endfunction

    virtual function int get_cswitch_en_idx();
        arr_row_data_t cswitch_arr_copy = systolic_array_item.cswitch_arr;

        for(int col=0; col < sauria_pkg::X; col++)begin
            if (cswitch_arr_copy == CS_LAST_IDX) return sauria_pkg::X - 1 - col;
            cswitch_arr_copy >>= 1;
        end
    endfunction



    /***********COMPUTATION FUNCTIONS************************* */

    virtual function void get_ifmaps_rows();
        for(int c=0; c < incntlim; c++)begin
            for(int row=0; row < sauria_pkg::Y; row++)begin
                ifmaps_feeder_data[row].ifmaps_data.push_back(a_arr_entries[0][row]);

                if(row == 0 )
                    `sauria_info(message_id, $sformatf("IFMAPS_ROW: %0d_DATA: 0x%0h C: %0d",  row, a_arr_entries[0][row], c))

            end
            a_arr_entries.pop_front();
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
            b_arr_entries.pop_front();
        end
    endfunction

     virtual function void calculate_mac();
        int unsigned  accum;
        int unsigned  product;

        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                for(int c=0; c < incntlim; c++)begin
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

        wr_ptr = !wr_ptr;
    endfunction

    virtual function void check_scan_chain_out_data();

        int q_size = rd_ptr ? psum_scan_chain_out_b.size() : psum_scan_chain_out_a.size();
        
        if (q_size > 0)begin

            case(rd_ptr)
                0: psum_col = psum_scan_chain_out_a.pop_front();
                1: psum_col = psum_scan_chain_out_b.pop_front();
            endcase

            if (psum_col != systolic_array_item.o_c_arr)begin
                `sauria_error(message_id, "Mismatch Mac PSUMS and Scan Chain Outputs")
                for(int row=0; row < sauria_pkg::Y; row++)
                    `sauria_error(message_id, $sformatf("Col: %0d Row: %0d MAC_PSUMS: 0x%0h  Scan_Chain_Out: 0x%0h",
                    sauria_pkg::X - q_size, row, psum_col[row],systolic_array_item.o_c_arr[row] ))

            end
            else begin
                if (rd_ptr)
                    `sauria_info(message_id, $sformatf("MAC PSUM and Scan Chain Out Match  PSUM_SCAN_CHAIN_OUT_SIZE: %0d", psum_scan_chain_out_b.size()))
                else
                    `sauria_info(message_id, $sformatf("MAC PSUM and Scan Chain Out Match  PSUM_SCAN_CHAIN_OUT_SIZE: %0d", psum_scan_chain_out_a.size()))
            end

            q_size = rd_ptr ? psum_scan_chain_out_b.size() : psum_scan_chain_out_a.size();
            if (q_size == 0) rd_ptr = !rd_ptr;

        end
    endfunction

    virtual function void update_ifmaps_feeder_data(a_arr_data_t a_arr);
        int last_valid_queue_elem = (ifmaps_feeder_out_data.size() < sauria_pkg::Y) ? ifmaps_feeder_out_data.size() : sauria_pkg::Y;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            
            if ((i == sauria_pkg::Y - 1 -  (idx_curr_comp - incntlim)) && (idx_curr_comp >= incntlim) && (!count_next_comp))
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
            
            if ((i == sauria_pkg::X - 1 -  (idx_curr_comp - incntlim)) && (idx_curr_comp >= incntlim) && (!count_next_comp))
                break;

            for(int col=0; col < sauria_pkg::X; col++)begin

                //Find first invalid element
                if(!weights_feeder_out_data[i].arr_byte_valid[col]) begin
                    weights_feeder_out_data[i].arr_byte_valid[col] = 1'b1; //Set To Valid
                    weights_feeder_out_data[i].b_arr[col]          = b_arr[col];
                    
                    if ((i == 0)  && (col < last_valid_queue_elem)) 
                        last_valid_queue_elem  = col + 1;
                    else if (count_next_comp)
                        last_valid_queue_elem = i + col + 1;

                    `sauria_info(message_id, $sformatf("Valid elem_idx: %0d b_arr_col[%0d]: 0x%0h Entry_Val: 0x%0h Last_Valid_Elem: %0d",
                    i, col, b_arr[col], b_arr, last_valid_queue_elem))
                    break;    
                end
            end
            
        end
    endfunction

    virtual function void save_preload_values();
        for(int col=0; col < sauria_pkg::X; col++)begin
            for(int row=0; row < sauria_pkg::Y; row++)
                preload_psums_reg[row][col] = systolic_array_item.arr_psum_reserve_reg[row][col];
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
   
endclass