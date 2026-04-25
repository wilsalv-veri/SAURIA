class sauria_ifmaps_feeder_seq_item extends uvm_sequence_item;

    // Data Inputs
    srama_data_t               srama_data;      // Data bus from SRAMA

    // Row Feeder control inputs
    bit					       feeder_en;        // Enable for counters and Row feeders
    bit                        feeder_clear;     // Clear signal for counters and Row feeder buffers
    bit                        act_valid;        // Flag: valid inputs at feeder
   
    // FIFO control inputs
    bit                        start_feeding;
    bit                        clearfifo;        // Clear signal for FIFO
    bit                        pipeline_en;      // Systolic Array pipeline enable
    bit                        pop_en;           // FIFO pop enable

    // Control Outputs
    bit                        srama_select;
    bit                        done; 	        // Current context counters done flag
    bit                        til_done; 	    // Tiling counters done flag
    srama_addr_t               srama_addr;      // Address towards SRAMA
    bit                        srama_rden;      // Read Enable for SRAMA
	bit                        fifo_empty; 	    // FIFO empty flag (any)
    bit                        fifo_full; 	    // FIFO full flag (any)
    bit                        feeder_stall;    // Feeder stall flag (any)

    // Status Outputs
    bit                        act_deadlock;    // Deadlock flag

    // Data Outputs
	a_arr_data_t               a_arr;           // Activation feeding stream

    `uvm_object_utils_begin(sauria_ifmaps_feeder_seq_item)
        `uvm_field_int(done,         UVM_ALL_ON)
        `uvm_field_int(til_done,     UVM_ALL_ON)
        `uvm_field_int(srama_addr,   UVM_ALL_ON)
        `uvm_field_int(srama_rden,   UVM_ALL_ON)
        `uvm_field_int(fifo_empty,   UVM_ALL_ON)
        `uvm_field_int(fifo_full,    UVM_ALL_ON)
        `uvm_field_int(feeder_stall, UVM_ALL_ON)
        `uvm_field_int(act_deadlock, UVM_ALL_ON)
        `uvm_field_int(a_arr,        UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="sauria_ifmaps_feeder_seq_item");
        super.new(name);
    endfunction
endclass