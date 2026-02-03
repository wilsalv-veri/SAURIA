`ifndef SAURIA_ENV_PKG
`define SAURIA_ENV_PKG

package sauria_env_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_scbd_pkg::*;

    `include "sauria_data_generator.sv"

    `include "sauria_axi4_lite_driver.sv"
    `include "sauria_axi4_lite_agent.sv"
   
    `include "sauria_axi4_driver.sv"
    `include "sauria_axi4_monitor.sv"
    `include "sauria_axi4_agent.sv"
    
    `include "sauria_env.sv"

endpackage

`endif //SAURIA_ENV_PKG

    
