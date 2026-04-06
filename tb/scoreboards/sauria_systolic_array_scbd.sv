class sauria_systolic_array_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_systolic_array_scbd)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_SCBD";

    `uvm_analysis_imp_decl (_systolic_array_info)
    uvm_analysis_imp_systolic_array_info #(sauria_systolic_array_seq_item, sauria_systolic_array_scbd)                   receive_systolic_array_info;

    sauria_computation_params       computation_params;
    sauria_systolic_array_model     systolic_array_model;
    
    scan_chain_data_t               psum_shift_reg[$];
    scan_chain_data_t               psum_col;

    int                             cswitch_arr_en_idx,
                                    cswitch_done_count,
                                    cswitch_idx;

    bit                             first_ctx_switch;
            
    function new(string name="sauria_systolic_array_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_systolic_array_info          = new("SAURIA_SYSTOLIC_ARRAY_IMP", this);
        systolic_array_model                 = sauria_systolic_array_model::type_id::create("sauria_systolic_array_model");
        
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.main_controller_cfg_shared);
        systolic_array_model.set_incntlim(computation_params.incntlim);
    
        wait(computation_params.psums_mgr_cfg_shared);
        systolic_array_model.set_psums_preload_en(computation_params.psums_preload_en);
    endtask

    function write_systolic_array_info(sauria_systolic_array_seq_item systolic_array_info);
        
        if (systolic_array_info.reg_clear)
            systolic_array_model.reset();
        else begin
            //Normal Operation
            if (systolic_array_info.cscan_valid)
                process_scan_chain(systolic_array_info.cscan_en, systolic_array_info.i_c_arr, 
                                   systolic_array_info.o_c_arr, systolic_array_info.arr_psum_reserve_reg);
                
            if (systolic_array_info.cswitch_valid)begin
                first_ctx_switch = systolic_array_info.cswitch_arr == CS_FIRST_IDX;
                
                cswitch_arr_en_idx = get_cswitch_en_idx(systolic_array_info.cswitch_arr);
                cswitch_done_count = systolic_array_info.cswitch_done_count;
                cswitch_idx = (cswitch_done_count > 0) ? sauria_pkg::X - 1 + cswitch_done_count : cswitch_arr_en_idx;
                
                process_context_switch(first_ctx_switch, cswitch_idx, systolic_array_info.pre_cswitch_arr_psum_reserve_reg,
                                    systolic_array_info.arr_psum_accum_in, systolic_array_info.arr_psum_accum_out,systolic_array_info.arr_psum_reserve_reg);
            end
            //FIXME: wilsalv :Re-enable
            //process_mac();
        end

    endfunction

    virtual function void process_scan_chain(bit cscan_en, ref scan_chain_data_t i_c_arr, 
                                            ref scan_chain_data_t o_c_arr, ref arr_psum_reg_t arr_psum_reserve_reg);

        if (cscan_en || systolic_array_model.is_cscan_last_shift()) begin

            if (systolic_array_model.is_scan_chain_out_data_valid() 
            && !systolic_array_model.is_scan_chain_fifo_empty())
                check_scan_chain_out_data(o_c_arr);
            
            systolic_array_model.add_scan_chain_in_data(i_c_arr);
        end
        else if (systolic_array_model.is_cscan_done())begin
            systolic_array_model.save_preload_values(arr_psum_reserve_reg);
            check_array_psum_reg(arr_psum_reserve_reg);
            systolic_array_model.reset_cscan();
        end
    endfunction

    virtual function void process_context_switch(bit first_ctx_switch, int cswitch_idx, ref arr_psum_reg_t pre_cswitch_arr_psum_reserve_reg,
                                                ref arr_psum_reg_t arr_psum_accum_in,   ref arr_psum_reg_t arr_psum_accum_out, 
                                                ref arr_psum_reg_t arr_psum_reserve_reg);
                                                
        
        if (first_ctx_switch) 
            systolic_array_model.set_pre_cswitch_arr_psum_reserve_reg(pre_cswitch_arr_psum_reserve_reg);
        
        pre_cswitch_arr_psum_reserve_reg = systolic_array_model.get_pre_cswitch_arr_psums_reserve_reg();
        check_accum_psum_reserve_swap(cswitch_idx, pre_cswitch_arr_psum_reserve_reg, 
                                    arr_psum_accum_in, arr_psum_accum_out, arr_psum_reserve_reg);
    endfunction

    //FIXME: wilsalv :Re-enable
    /* 
    virtual function void process_mac();

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

    endfunction*/

    virtual function void check_scan_chain_out_data(ref scan_chain_data_t o_c_arr);

        psum_col = systolic_array_model.get_scan_chain_out_col();

        if (psum_col != o_c_arr)begin
            `sauria_error(message_id, "Mismatch Mac PSUMS and Scan Chain Outputs")
            for(int row=0; row < sauria_pkg::Y; row++)
                `sauria_error(message_id, $sformatf("Col: %0d Row: %0d MAC_PSUMS: 0x%0h  Scan_Chain_Out: 0x%0h",
                systolic_array_model.get_curr_scan_chain_out_col_idx(), row, psum_col[row],o_c_arr[row] ))
        end
        /*else begin
            if (rd_ptr)
                `sauria_info(message_id, $sformatf("MAC PSUM and Scan Chain Out Match  PSUM_SCAN_CHAIN_OUT_SIZE: %0d", psum_scan_chain_out_b.size()))
            else
                `sauria_info(message_id, $sformatf("MAC PSUM and Scan Chain Out Match  PSUM_SCAN_CHAIN_OUT_SIZE: %0d", psum_scan_chain_out_a.size()))
        end*/

    endfunction

    virtual function void check_array_psum_reg(ref arr_psum_reg_t arr_psum_reserve_reg);
        psum_shift_reg = systolic_array_model.get_psum_shift_reg_clone();
            
        for(int col=0; col < sauria_pkg::X; col++)begin
    
            for(int row=0; row < sauria_pkg::Y; row++)begin
                if (psum_shift_reg[col][row] != arr_psum_reserve_reg[row][col])
                    `sauria_error(message_id, $sformatf("Array PSUM Reserve Register Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h", 
                row, col, psum_shift_reg[col][row], arr_psum_reserve_reg[row][col]))
            end
        end
    endfunction

    virtual function void check_accum_psum_reserve_swap(int cswitch_idx, ref arr_psum_reg_t pre_cswitch_arr_psum_reserve_reg,
                                                        ref arr_psum_reg_t arr_psum_accum_in, ref arr_psum_reg_t arr_psum_accum_out, 
                                                        ref arr_psum_reg_t arr_psum_reserve_reg);
       
        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                if ((row + col) == cswitch_idx) begin
                  
                    if (pre_cswitch_arr_psum_reserve_reg[row][col] != arr_psum_accum_in[row][col])
                        `sauria_error(message_id, $sformatf("Accumulator Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h",
                        row, col, pre_cswitch_arr_psum_reserve_reg[row][col], arr_psum_accum_in[row][col]))
                
                    if (arr_psum_accum_out[row][col] != arr_psum_reserve_reg[row][col])
                        `sauria_error(message_id, $sformatf("PSUM Reserve Reg Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h",
                        row, col, arr_psum_accum_out[row][col], arr_psum_reserve_reg[row][col]))
                      
                end
            end
        end

    endfunction

    virtual function int get_cswitch_en_idx(arr_row_data_t cswitch_arr);
        for(int col=0; col < sauria_pkg::X; col++)begin
            if (cswitch_arr == CS_LAST_IDX) return sauria_pkg::X - 1 - col;
            cswitch_arr >>= 1;
        end
    endfunction

endclass