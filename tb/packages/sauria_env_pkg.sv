`ifndef SAURIA_ENV_PKG
`define SAURIA_ENV_PKG

package sauria_env_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_scbd_pkg::*;
    import sauria_cfg_regs_pkg::*;

    `include "sauria_data_generator.sv"

    `include "sauria_axi4_lite_driver.sv"
    `include "sauria_axi4_lite_seqr.sv" 
    `include "sauria_axi4_lite_adapter.sv"
    `include "sauria_axi4_lite_agent.sv"
    
    `include "sauria_axi4_driver.sv"
    `include "sauria_axi4_monitor.sv"
    `include "sauria_axi4_agent.sv"
    
    `include "sauria_main_controller_monitor.sv"
    `include "sauria_main_controller_agent.sv"
    
    `include "sauria_ifmaps_feeder_monitor.sv"
    `include "sauria_ifmaps_feeder_agent.sv"

    `include "sauria_weights_feeder_monitor.sv"
    `include "sauria_weights_feeder_agent.sv"

    `include "sauria_systolic_array_monitor.sv"
    `include "sauria_systolic_array_agent.sv"
    
    `include "sauria_psums_mgr_monitor.sv"
    `include "sauria_psums_mgr_agent.sv"

    `include "sauria_env.sv"

endpackage

`endif //SAURIA_ENV_PKG

    
