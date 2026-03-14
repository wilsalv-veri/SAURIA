class sauria_systolic_array_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_systolic_array_scbd)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_SCBD";

    `uvm_analysis_imp_decl (_systolic_array_info)
    uvm_analysis_imp_systolic_array_info #(sauria_systolic_array_seq_item, sauria_systolic_array_scbd)                   receive_systolic_array_info;

    sauria_systolic_array_seq_item          systolic_array_item;
    
    int                                     cscan_idx;
    bit                                     cscan_done;
    bit                                     cscan_last_shift;
    bit                                     cs_last_shift;
   
    scan_chain_data_t                       shift_reg_copy[$];
    arr_psum_reg_t                          pre_cswitch_arr_psum_reserve_reg;
    
    function new(string name="sauria_systolic_array_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_systolic_array_info          = new("SAURIA_SYSTOLIC_ARRAY_IMP", this);
    endfunction

    function write_systolic_array_info(sauria_systolic_array_seq_item systolic_array_info);
        systolic_array_item = systolic_array_info;
        check_scan_chain();
        check_context_switch();
    endfunction

    virtual function void check_scan_chain();
        if (systolic_array_item.cscan_en | cscan_last_shift) add_scan_data();
        else if (cscan_done)begin
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

    virtual function void add_scan_data();
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

        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                if ((row + col) == cswitch_idx) begin
                    `sauria_info(message_id, $sformatf("CSWITCH_ARR_EN ROW: %0d COL: %0d CSWITCH_IDX: %0d CSWITCH_ARR_EN_IDX: %0d CSWITCH_ARR: 0x%0h CSWITCH_DONE_COUNT: %0d ACCUM: 0x%0h", 
                    row, col, cswitch_idx, cswitch_arr_en_idx, systolic_array_item.cswitch_arr, cswitch_done_count, systolic_array_item.arr_psum_accum_in[row][col] ))
                
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

endclass