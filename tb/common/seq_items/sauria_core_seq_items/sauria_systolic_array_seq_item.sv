class sauria_systolic_array_seq_item extends uvm_sequence_item;

    // Data Inputs
    a_arr_data_t      a_arr;	 // Activation operands
	b_arr_data_t      b_arr;	 // Weight operands
	scan_chain_data_t i_c_arr;	 // MAC inputs (preload / out chain)
	
	// Control Inputs
    bit                 reg_clear;   // PE Register clear
	
    bit                 scan_cswitch_valid;

    bit                 act_start_feeding;
    bit                 wei_start_feeding;
    bit					pipeline_en; // Global pipeline enable (for stalls)
    bit                 act_data_valid;
    bit                 wei_data_valid;

    arr_row_data_t      cswitch_arr; // Accumulator context switches
    int                 cswitch_done_count;
    bit					cscan_en;    // Output Scanchains Enable
    threshold_t         thres;       // Threshold for bit negligence in zero detection

	// Data Outputs
	scan_chain_data_t   o_c_arr;     // MAC outputs (preload / out chain)

    arr_psum_reg_t      arr_psum_reserve_reg;
    arr_psum_reg_t      pre_cswitch_arr_psum_reserve_reg;
    
    arr_psum_reg_t      arr_psum_accum_in;
    arr_psum_reg_t      arr_psum_accum_out;

    `uvm_object_utils_begin(sauria_systolic_array_seq_item)
        `uvm_field_int(a_arr,       UVM_ALL_ON)
        `uvm_field_int(b_arr,       UVM_ALL_ON)
        `uvm_field_int(i_c_arr,     UVM_ALL_ON)
        `uvm_field_int(reg_clear,   UVM_ALL_ON)
        
        `uvm_field_int(pipeline_en, UVM_ALL_ON)
        `uvm_field_int(act_data_valid, UVM_ALL_ON)
        `uvm_field_int(wei_data_valid, UVM_ALL_ON)
        
        `uvm_field_int(cswitch_arr, UVM_ALL_ON)
        `uvm_field_int(cscan_en,    UVM_ALL_ON)
        `uvm_field_int(thres,       UVM_ALL_ON)
        `uvm_field_int(o_c_arr,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="sauria_systolic_array_seq_item");
        super.new(name);
    endfunction

endclass