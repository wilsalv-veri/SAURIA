interface sauria_weights_feeder_ifc import sauria_pkg::*;();

    // Clk, RST
	logic 				         clk;
	logic					     rstn;

	// Data Inputs
    logic [SRAMB_W-1:0]          sramb_data;       // Data bus from SRAMB

    // Column Feeder control inputs
    logic					     feeder_en;        // Enable for counters and Column feeders
    logic                        feeder_clear;     // Clear signal for counters and Column feeder buffers
    logic                        wei_valid;        // Flag: valid inputs at feeder
    
    // FIFO control inputs
    logic                         data_valid;
    logic                         clearfifo;        // Clear signal for FIFO
    logic                         pipeline_en;      // Systolic Array pipeline enable
    logic                         pop_en;           // FIFO pop enable

    // Control Outputs
    logic                        done; 	        // Current context counters done flag
    logic                        til_done; 	    // Tiling counters done flag
    logic [ADRB_W-1:0]           sramb_addr;       // Address towards SRAMB
    logic                        sramb_rden;       // Read Enable for SRAMB
	logic                        fifo_empty; 	    // FIFO empty flag (any)
    logic                        fifo_full; 	    // FIFO full flag (any)
    logic                        feeder_stall;     // Feeder stall flag (any)

    // Status Outputs
    logic                        wei_deadlock;     // Deadlock flag

    // Data Outputs
	logic [0:X-1][IB_W-1:0]      b_arr;             // Weights feeding stream

endinterface