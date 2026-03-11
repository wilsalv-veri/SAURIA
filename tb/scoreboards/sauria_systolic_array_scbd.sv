class sauria_systolic_array_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_systolic_array_scbd)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_SCBD";

    parameter CS_FIRST_IDX = arr_row_data_t'('h8000);
    parameter CS_LAST_IDX  = arr_row_data_t'('h0001);
    
    `uvm_analysis_imp_decl (_systolic_array_info)
    uvm_analysis_imp_systolic_array_info #(sauria_systolic_array_seq_item, sauria_systolic_array_scbd)                   receive_systolic_array_info;

    sauria_systolic_array_seq_item          systolic_array_item;
    
    int                                     cscan_idx;
    bit                                     cscan_done;
    bit                                     cscan_last_shift;
    bit                                     cs_last_shift;

    scan_chain_data_t                       shift_reg_copy[$];
    arr_psum_reg_t                          psum_reserve_reg_copy, accum_copy;

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
        if (systolic_array_item.cswitch_arr == CS_FIRST_IDX) begin
                psum_reserve_reg_copy = systolic_array_item.arr_psum_reserve_reg;
                accum_copy            = systolic_array_item.arr_psum_accum;
            end
        else if (systolic_array_item.cswitch_arr == CS_LAST_IDX) cs_last_shift = 1'b1;
        else if (cs_last_shift) begin
            cs_last_shift = 1'b0;
            check_register_value_swap();
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
                else 
                    `sauria_info(message_id, $sformatf("PSUM Reserve Register Match Row: %0d Col: %0d", row, col))
            end
        end
        shift_reg_copy.delete();
    endfunction

    virtual function void check_register_value_swap();
        
        //TODO: wilsalv : Enable Check
        /* 
        for(int row=0; row < sauria_pkg::Y; row++)begin
            for(int col=0; col < sauria_pkg::X; col++)begin
                if (accum_copy[row][col] != systolic_array_item.arr_psum_reserve_reg[row][col])
                    `sauria_error(message_id, $sformatf("PSUM Reserve Register Value Mismatch During Context Switch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h", 
                row, col, accum_copy[row][col], systolic_array_item.arr_psum_reserve_reg[row][col]))
                else 
                    `sauria_info(message_id, $sformatf("PSUM Reserve Register Value Match During Context Switch Row: %0d Col: %0d Val: 0x%0h", 
                row, col, accum_copy[row][col]))

                if (psum_reserve_reg_copy[row][col] != systolic_array_item.arr_psum_accum[row][col])
                    `sauria_error(message_id, $sformatf("Accumulator Value Mismatch During Context Switch Row: %0d Col: %0d Exp: 0x%0h Act: 0x%0h", 
                row, col, accum_copy[row][col], systolic_array_item.arr_psum_accum[row][col]))
                else 
                    `sauria_info(message_id, $sformatf("Accumulator Value Match During Context Switch Row: %0d Col: %0d Val: 0x%0h", 
                row, col, accum_copy[row][col]))
                
            end
        end
        */
    endfunction

endclass