`ifndef SAURIA_SCBD_PKG
`define SAURIA_SCBD_PKG

package sauria_scbd_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_inv_feeders_pkg::*;
    import sauria_golden_model_pkg::*;
    
    `include "sauria_dma_req_addr_scbd.sv"
    `include "sauria_main_controller_scbd.sv"
    `include "sauria_ifmaps_feeder_scbd.sv"
    `include "sauria_weights_feeder_scbd.sv"
    `include "sauria_systolic_array_scbd.sv"
    `include "sauria_psums_mgr_scbd.sv"
    
endpackage

`endif //SAURIA_SCBD_PKG