interface sauria_ifmaps_feeder_ifc import sauria_pkg::*;();

    logic 				         clk;
	
    logic                        srama_select;

    // Row Feeder control inputs
    logic                        start;            // Flag: first inputs of current context
    logic					     feeder_en;        // Enable for counters and Row feeders
    logic                        feeder_clear;     // Clear signal for counters and Row feeder buffers
    logic                        act_valid;        // Flag: valid inputs at feeder
    
    // FIFO control inputs
    logic                         data_valid;
    logic                         clearfifo;        // Clear signal for FIFO
    logic                         pipeline_en;      // Systolic Array pipeline enable
    logic                         pop_en;           // FIFO pop enable

    // Data Inputs
    logic [SRAMA_W-1:0]          srama_data;       // Data bus from SRAMA

    // Control Outputs
    logic                        done; 	        // Current context counters done flag
    logic                        til_done; 	    // Tiling counters done flag
    logic [ADRA_W-1:0]           srama_addr;    // Address towards SRAMA
    logic                        srama_rden;    // Read Enable for SRAMA
	logic                        fifo_empty; 	// FIFO empty flag (any)
    logic                        fifo_full; 	// FIFO full flag (any)
    logic                        feeder_stall;  // Feeder stall flag (any)

    // Status Outputs
    logic                        act_deadlock;  // Deadlock flag

    // Data Outputs
	logic [0:Y-1][IA_W-1:0]      a_arr;         // Activation feeding stream

endinterface