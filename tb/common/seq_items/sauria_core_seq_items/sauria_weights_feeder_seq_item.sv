class sauria_weights_feeder_seq_item extends uvm_sequence_item;

    sramb_data_t   sramb_data;       // Data bus from SRAMB

    // Column Feeder control inputs
    bit			  feeder_en;        // Enable for counters and Column feeders
    bit           feeder_clear;     // Clear signal for counters and Column feeder buffers
    bit           wei_valid;        // Flag: valid inputs at feeder
    bit           data_valid;
    
    // FIFO control inputs
    bit           start_feeding;
    bit           clearfifo;        // Clear signal for FIFO
    bit           pipeline_en;      // Systolic Array pipeline enable
    bit           pop_en;           // FIFO pop enable

    // Control Outputs
    bit           done; 	        // Current context counters done flag
    bit           til_done; 	    // Tiling counters done flag
    sramb_addr_t  sramb_addr;       // Address towards SRAMB
    bit           sramb_rden;       // Read Enable for SRAMB
	bit           fifo_empty; 	    // FIFO empty flag (any)
    bit           fifo_full; 	    // FIFO full flag (any)
    bit           feeder_stall;     // Feeder stall flag (any)

    // Status Outputs
    bit           wei_deadlock;     // Deadlock flag

    // Data Outputs
	b_arr_data_t  b_arr;             // Weights feeding stream

    `uvm_object_utils_begin(sauria_weights_feeder_seq_item)
        `uvm_field_int(sramb_data,   UVM_ALL_ON)
        `uvm_field_int(feeder_en,    UVM_ALL_ON)
        `uvm_field_int(feeder_clear, UVM_ALL_ON)
        `uvm_field_int(wei_valid,    UVM_ALL_ON)
        `uvm_field_int(til_done, 	 UVM_ALL_ON)  
        `uvm_field_int(sramb_addr,   UVM_ALL_ON)
        `uvm_field_int(sramb_rden,   UVM_ALL_ON)
        `uvm_field_int(fifo_empty, 	 UVM_ALL_ON)
        `uvm_field_int(fifo_full, 	 UVM_ALL_ON) 
        `uvm_field_int(feeder_stall, UVM_ALL_ON)
        `uvm_field_int(done,         UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="sauria_weights_feeder_seq_item");
        super.new(name);
    endfunction
endclass