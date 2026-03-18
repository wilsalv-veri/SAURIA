interface sauria_systolic_array_ifc import sauria_pkg::*;();

    logic 				    clk;
	logic				    rstn;

	// Data Inputs
    logic [0:Y-1][IA_W-1:0] a_arr;	     // Activation operands
	logic [0:X-1][IB_W-1:0]	b_arr;	     // Weight operands
	logic [0:Y-1][OC_W-1:0] i_c_arr;	 // MAC inputs (preload / out chain)
	
    logic                   act_data_valid;
    logic                   wei_data_valid;
    
    logic                   act_pop_en;
    logic                   wei_pop_en;
    
	// Control Inputs
    logic                   reg_clear;   // PE Register clear
	
    logic					pipeline_en; // Global pipeline enable (for stalls)
    logic [0:X-1]			cswitch_arr; // Accumulator context switches
    logic					cscan_en;    // Output Scanchains Enable
    logic [TH_W-1:0]        thres;       // Threshold for bit negligence in zero detection

	// Data Outputs
	logic [0:Y-1][OC_W-1:0] o_c_arr;     // MAC outputs (preload / out chain)

    //Internal Signals 
    logic [Y-1:0][X-1:0][OC_W-1:0] arr_psum_reserve_reg;
    logic [Y-1:0][X-1:0][OC_W-1:0] arr_psum_accum_in;
    logic [Y-1:0][X-1:0][OC_W-1:0] arr_psum_accum_out;

    clocking cswitch_done_cb @(negedge cswitch_arr[X-1]) ;
        //Used To Trigger End of CSWITCH 
    endclocking 

    clocking pipeline_en_cb @ (posedge pipeline_en);
        //Used to delay CSWITCH by 1 cycle
    endclocking
endinterface