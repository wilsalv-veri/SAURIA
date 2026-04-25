class sauria_systolic_array_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_systolic_array_scbd)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_SCBD";

    `uvm_analysis_imp_decl (_systolic_array_info)
    uvm_analysis_imp_systolic_array_info #(sauria_systolic_array_seq_item, sauria_systolic_array_scbd)                   receive_systolic_array_info;

    sauria_computation_params       computation_params;
    sauria_systolic_array_model     systolic_array_model;

    int                             cswitch_arr_en_idx,
                                    cswitch_done_count,
                                    cswitch_idx;

    bit                             first_ctx_switch;
    bit                             start_data_feed, data_feed_valid;
            
    function new(string name="sauria_systolic_array_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_systolic_array_info          = new("SAURIA_SYSTOLIC_ARRAY_IMP", this);
        systolic_array_model                 = sauria_systolic_array_model::type_id::create("sauria_systolic_array_model");
        
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")

        systolic_array_model.set_computation_params(computation_params);
    endfunction

    function write_systolic_array_info(sauria_systolic_array_seq_item systolic_array_info);
        systolic_array_scan_chain_result_t     scan_chain_result;
        systolic_array_context_switch_result_t context_switch_result;
        
        if (systolic_array_info.reg_clear)
            systolic_array_model.reset();
        else begin
            //Normal Operation
            if (systolic_array_info.cscan_valid) begin
                scan_chain_result = systolic_array_model.observe_scan_chain_event(systolic_array_info.cscan_en,
                                                                                  systolic_array_info.i_c_arr,
                                                                                  systolic_array_info.arr_psum_reserve_reg);

                if (scan_chain_result.valid_scan_chain_out)
                    check_scan_chain_out_data(scan_chain_result.scan_chain_out_col_idx,
                                              scan_chain_result.exp_scan_chain_out_col,
                                              systolic_array_info.o_c_arr);
                else if (scan_chain_result.valid_psum_reserve_reg_snapshot)
                    check_array_psum_reg(scan_chain_result.exp_arr_psum_reserve_reg,
                                         systolic_array_info.arr_psum_reserve_reg);
            end

            if (systolic_array_info.cswitch_valid)begin
                first_ctx_switch = systolic_array_info.cswitch_arr == CS_FIRST_IDX;
                
                cswitch_arr_en_idx = get_cswitch_en_idx(systolic_array_info.cswitch_arr);
                cswitch_done_count = systolic_array_info.cswitch_done_count;
                cswitch_idx = (cswitch_done_count > 0) ? sauria_pkg::X - 1 + cswitch_done_count : cswitch_arr_en_idx;

                context_switch_result = systolic_array_model.observe_context_switch(first_ctx_switch,
                                                                                    systolic_array_info.pre_cswitch_arr_psum_reserve_reg);

                if (context_switch_result.valid_context_switch)
                    check_accum_psum_reserve_swap(cswitch_idx,
                                                  context_switch_result.exp_pre_cswitch_arr_psum_reserve_reg,
                                                  systolic_array_info.arr_psum_accum_in,
                                                  systolic_array_info.arr_psum_accum_out,
                                                  systolic_array_info.arr_psum_reserve_reg);
            
            
            end
            
            start_data_feed = systolic_array_info.act_start_feeding || systolic_array_info.wei_start_feeding;
            data_feed_valid = systolic_array_info.act_data_valid    || systolic_array_info.wei_data_valid;
            systolic_array_model.observe_mac_context_data(start_data_feed, data_feed_valid, systolic_array_info.a_arr, systolic_array_info.b_arr);

            
        end

    endfunction

    virtual function void check_scan_chain_out_data(int col_idx,
                                                    scan_chain_data_t exp_psum_col,
                                                    ref scan_chain_data_t o_c_arr);
        if (exp_psum_col != o_c_arr)begin
            `sauria_error(message_id, "Mismatch Mac PSUMS and Scan Chain Outputs")
            for(int row=0; row < sauria_pkg::Y; row++)
                `sauria_error(message_id, $sformatf("Col: %0d Row: %0d MAC_PSUMS: 0x%0h  Scan_Chain_Out: 0x%0h",
                col_idx , row, exp_psum_col[row],o_c_arr[row] ))
        end
    
    endfunction

    virtual function void check_array_psum_reg(arr_psum_reg_t exp_arr_psum_reserve_reg,
                                               ref arr_psum_reg_t arr_psum_reserve_reg);
        for(int col=0; col < sauria_pkg::X; col++)begin
    
            for(int row=0; row < sauria_pkg::Y; row++)begin
                if (exp_arr_psum_reserve_reg[row][col] != arr_psum_reserve_reg[row][col])
                    `sauria_error(message_id, $sformatf("Array PSUM Reserve Register Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h", 
                row, col, exp_arr_psum_reserve_reg[row][col], arr_psum_reserve_reg[row][col]))
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
                        `sauria_error(message_id, $sformatf("Accumulator Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h CSWITCH_IDX: %0d",
                        row, col, pre_cswitch_arr_psum_reserve_reg[row][col], arr_psum_accum_in[row][col], cswitch_idx))
                
                    if (arr_psum_accum_out[row][col] != arr_psum_reserve_reg[row][col])
                        `sauria_error(message_id, $sformatf("PSUM Reserve Reg Context Switch Mismatch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h CSWITCH_IDX: %0d",
                        row, col, arr_psum_accum_out[row][col], arr_psum_reserve_reg[row][col], cswitch_idx))
                      
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