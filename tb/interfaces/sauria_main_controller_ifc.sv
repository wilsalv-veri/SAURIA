interface sauria_main_controller_ifc import sauria_pkg::*;();

    // Clk, RST
	logic          clk;
	logic          rstn;

    // Control Outputs (to Feeders)
    logic	       act_feeder_en;    // Enable for Row feeders
    logic          act_feeder_clear; // Clear signal Row feeder buffers
    logic          act_valid;        // Flag: valid inputs at feeder
    logic          act_start;        // Flag: first inputs of current context
    logic          act_finalpush;    // Flag: push of last buffer values
    logic          act_cnt_en;       // Enable for counters
    logic          act_cnt_clear;    // Clear signal for counters
    logic          act_clearfifo;    // Clear signal for FIFO
    logic          act_pop_en;       // FIFO pop enable
    logic          act_finalctx;     // Final context flag for activation counters
    logic	       wei_feeder_en;    // Enable for Column feeders
    logic          wei_feeder_clear; // Clear signal Column feeder buffers
    logic          wei_valid;        // Flag: valid inputs at feeder
    logic          wei_start;        // Flag: first inputs of current context
    logic          wei_finalpush;    // Flag: push of last buffer values
    logic          wei_cnt_en;       // Enable for counters
    logic          wei_cnt_clear;    // Clear signal for counters
    logic          wei_clearfifo;    // Clear signal for FIFO
    logic          wei_pop_en;       // FIFO pop enable
    logic          wei_cswitch;      // Context switch flag for weight counters

	// Control Outputs (Output Buffer)
    logic	       outbuf_start;     // Start flag for output buffer
    logic          outbuf_reset;     // Output buffer state Reset

    // Control Outputs (to Array)
    logic          sa_clear;         // Clear signal for SA internal registers
    logic          pipeline_en;      // Pipeline Enable signal for Array and Feeders
    logic [0:X-1]  cswitch_arr;      // Array Accumulator context switches

    // Control Outputs (to Interface)
    logic          feed_deadlock;    // Deadlock flag between feeders
    logic [4:0]    ctx_status;       // Context FSM status
    logic [4:0]    feed_status;      // Feeders FSM status
    logic          done;              // Finish flag

endinterface