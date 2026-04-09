
interface sauria_psums_mgr_ifc import sauria_pkg::*;();
    
    // Clk, RST
	logic 				 clk;
	logic			     rstn;

    logic                cnt_en;
    logic                shift_reg_shift;
    
    // Data Inputs from Memory
    logic [SRAMC_W-1:0]          sramc_rdata;      // Read data bus from SRAMC

    // Control Outputs to Memory
    logic [ADRC_W-1:0]           sramc_addr;       // Address towards SRAMC
    logic                        sramc_wren;       // Write Enable for SRAMC
    logic                        sramc_rden;       // Read Enable for SRAMC
    logic [0:SRAMC_N-1]          sramc_wmask;      // Write Mask for SRAMC

    // Control Outputs to Array
    logic                        cscan_en;         // Output Scan-Chain Enable

    // Data Outputs to Memory
    logic [SRAMC_W-1:0]          sramc_wdata;      // Write data bus towards SRAMC

    // Data Inputs from Array
	logic [Y-1:0][OC_W-1:0] 	 i_c_arr;	        // MAC outputs (scan chain)

    // Data Outputs to Array
	logic [Y-1:0][OC_W-1:0]  	 o_c_arr;             // MAC preload values (scan chain)

    clocking sramc_read_cb @(posedge clk iff (sramc_rden == 1'b1) ); 
        input sramc_addr; 
        input sramc_rdata;
        input sramc_wmask;
    endclocking

    clocking sramc_new_context_read_cb @ (posedge sramc_rden);
        //
    endclocking

    clocking sramc_write_cb @(posedge clk iff (sramc_wren == 1'b1) );
        input sramc_wren; 
        input sramc_addr; 
        input sramc_wdata;
        input sramc_wmask;
    endclocking
    
    clocking sramc_new_context_write_cb @ (posedge sramc_wren);
        //
    endclocking

    clocking preload_values_cb @(posedge clk iff (cscan_en == 1'b1) );
        input cscan_en;
        input i_c_arr;
        input o_c_arr;
    endclocking
    
endinterface