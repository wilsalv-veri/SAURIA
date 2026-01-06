import uvm_pkg::*;

module SAURIA_tb_top;
   
    import sauria_tb_top_pkg::*;

    sauria_subsystem_ifc  sauria_subsystem_if();
    sauria_axi4_lite_ifc  axi4_lite_cfg_if();
    sauria_axi4_ifc       axi4_mem_if();

    virtual sauria_subsystem_ifc  sauria_subsystem_if_v;

    `include "sauria_subsystem_ifc_connections.sv"
   
    always #SAURIA_CLK_HALF_PERIOD sauria_subsystem_if.i_sauria_clk = ~sauria_subsystem_if.i_sauria_clk;
    always #SYSTEM_CLK_HALF_PERIOD sauria_subsystem_if.i_system_clk = ~sauria_subsystem_if.i_system_clk;

    initial begin
        sauria_subsystem_if_v = sauria_subsystem_if;
        init_sauria_subsystem_if(sauria_subsystem_if_v);
        toggle_reset(sauria_subsystem_if_v);
    end 

    initial begin
        uvm_config_db #(virtual sauria_subsystem_ifc)::set(null, "*", "sauria_ss_if",            sauria_subsystem_if);
        uvm_config_db #(virtual sauria_axi4_lite_ifc)::set(null, "*", "sauria_axi4_lite_cfg_if", axi4_lite_cfg_if);
        uvm_config_db #(virtual sauria_axi4_ifc     )::set(null, "*", "sauria_axi4_mem_if",      axi4_mem_if);
    end

    sauria_subsystem sauria_ss(.*);

    initial begin
        $display("TB_TOP running at time %0t", $time);     
        run_test();
        $dumpvars(0, SAURIA_tb_top);
        repeat (100) @ (posedge i_sauria_clk);
        $display("TB_TOP finished at time %0t", $time);
        $finish();
    end

endmodule