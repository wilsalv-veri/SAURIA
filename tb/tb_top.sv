import uvm_pkg::*;
import sauria_cfg_tests_pkg::*;

module SAURIA_tb_top;
   
    import sauria_tb_top_pkg::*;

    sauria_subsystem_ifc                  sauria_subsystem_if();
    sauria_df_controller_ifc              sauria_df_controller_if();
    sauria_axi4_lite_ifc                  axi4_lite_cfg_if();
    sauria_axi4_ifc                       axi4_mem_if();

    sauria_main_controller_ifc            sauria_main_controller_if();
    sauria_ifmaps_feeder_ifc              sauria_ifmaps_feeder_if();
    sauria_weights_feeder_ifc             sauria_weights_feeder_if();
    sauria_systolic_array_ifc             sauria_systolic_array_if();
    
    sauria_psums_mgr_ifc                  sauria_psums_mgr_if();
    sauria_psums_mgr_shift_reg_ifc        sauria_psums_mgr_shift_reg_if();

    virtual sauria_subsystem_ifc   sauria_subsystem_if_v;
    
    `include "sauria_subsystem_ifc_connections.sv"
    `include "sauria_df_controller_ifc_connections.sv"
    `include "sauria_main_controller_ifc_connections.sv"
    `include "sauria_ifmaps_feeder_ifc_connections.sv"
    `include "sauria_weights_feeder_ifc_connections.sv"
    `include "sauria_systolic_array_ifc_connections.sv"
    `include "sauria_psums_mgr_ifc_connections.sv"
    `include "sauria_psums_mgr_shift_reg_ifc_connections.sv"

    always #SAURIA_CLK_HALF_PERIOD sauria_subsystem_if.i_sauria_clk = ~sauria_subsystem_if.i_sauria_clk;
    always #SYSTEM_CLK_HALF_PERIOD sauria_subsystem_if.i_system_clk = ~sauria_subsystem_if.i_system_clk;

    initial begin
        sauria_subsystem_if_v = sauria_subsystem_if;
        init_sauria_subsystem_if(sauria_subsystem_if_v);
        toggle_reset(sauria_subsystem_if_v);
    end 

    initial begin
        uvm_config_db #(virtual sauria_subsystem_ifc)::set(              null, "*", "sauria_ss_if",                      sauria_subsystem_if);
        uvm_config_db #(virtual sauria_df_controller_ifc)::set(          null, "*", "sauria_df_ctrl_if",                 sauria_df_controller_if);
        
        uvm_config_db #(virtual sauria_axi4_lite_ifc)::set(              null, "*", "sauria_axi4_lite_cfg_if",           axi4_lite_cfg_if);
        uvm_config_db #(virtual sauria_axi4_ifc     )::set(              null, "*", "sauria_axi4_mem_if",                axi4_mem_if);
        
        uvm_config_db #(virtual sauria_main_controller_ifc)::set(        null, "*", "sauria_main_controller_if",         sauria_main_controller_if);
        uvm_config_db #(virtual sauria_ifmaps_feeder_ifc)::set(          null, "*", "sauria_ifmaps_feeder_if",           sauria_ifmaps_feeder_if);
        uvm_config_db #(virtual sauria_weights_feeder_ifc)::set(         null, "*", "sauria_weights_feeder_if",          sauria_weights_feeder_if);
        uvm_config_db #(virtual sauria_systolic_array_ifc)::set(         null, "*", "sauria_systolic_array_if",          sauria_systolic_array_if);
        
        uvm_config_db #(virtual sauria_psums_mgr_ifc)::set(              null, "*", "sauria_psums_mgr_if",               sauria_psums_mgr_if);
        uvm_config_db #(virtual sauria_psums_mgr_shift_reg_ifc)::set(    null, "*", "sauria_psums_mgr_shift_reg_if",     sauria_psums_mgr_shift_reg_if);
    end

    sauria_subsystem sauria_ss(.*);

    bind sauria_ss sauria_ss_assert #(CFG_AXI_ADDR_WIDTH,
                                      CFG_AXI_DATA_WIDTH,
    
                                      DATA_AXI_ADDR_WIDTH, 
                                      DATA_AXI_DATA_WIDTH,
                                      DATA_AXI_ID_WIDTH
                                    ) ss_assert(.*);

    
    
    bind sauria_ss sauria_ss_cov #(CFG_AXI_ADDR_WIDTH,
                                      CFG_AXI_DATA_WIDTH,
    
                                      DATA_AXI_ADDR_WIDTH, 
                                      DATA_AXI_DATA_WIDTH,
                                      DATA_AXI_ID_WIDTH
                                    ) ss_cov(.*);

    
    initial begin
        $display("TB_TOP running at time %0t", $time);     
        run_test();
        $dumpvars(0, SAURIA_tb_top);
        repeat (100) @ (posedge i_sauria_clk);
        $display("TB_TOP finished at time %0t", $time);
        $finish();
    end

endmodule