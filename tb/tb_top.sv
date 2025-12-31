import axi_pkg::*;
import sauria_pkg::*;
import sauria_addr_pkg::*;
import sauria_tb_top_pkg::*;

module SAURIA_tb_top;
    
    SAURIA_ss_ifc          sa_ss_ifc();
    virtual SAURIA_ss_ifc  sa_ss_ifc_v;

    `include "sauria_ss_interface_connections.sv"
   
    always #SAURIA_CLK_HALF_PERIOD sa_ss_ifc.i_sauria_clk = ~sa_ss_ifc.i_sauria_clk;
    always #SYSTEM_CLK_HALF_PERIOD sa_ss_ifc.i_system_clk = ~sa_ss_ifc.i_system_clk;

    initial begin
        sa_ss_ifc.i_sauria_clk = 0;
        sa_ss_ifc.i_system_clk = 0;

        sa_ss_ifc.i_sauria_rstn = 0;
        sa_ss_ifc.i_system_rstn = 0;

        sa_ss_ifc_v = sa_ss_ifc;
        toggle_reset(sa_ss_ifc_v);
    end 

    sauria_subsystem sauria_ss(
    // SAURIA Clk & RST @500M
	//.i_sauria_clk (sauria_clk),
	//.i_sauria_rstn (sauria_reset),
    // System Clk & RST @1500M
	//.i_system_clk (system_clk),
	//.i_system_rstn (system_reset),

    .*
    // Configuration AXI4-Lite SLAVE interface
   
    // Data AXI4 MASTER interface
    
    // Control FSM Interrupt

    // DMA Interrupt
    
    // SAURIA Interrupt
);

initial begin
    $display("TB_TOP running at time %0t", $time);     
    repeat(100) @ (posedge i_sauria_clk);
    $dumpvars(0, SAURIA_tb_top);
    $display("TB_TOP finished at time %0t", $time);
    $finish();
end

endmodule