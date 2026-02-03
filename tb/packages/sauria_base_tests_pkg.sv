`ifndef SAURIA_BASE_TESTS_PKG
`define SAURIA_BASE_TESTS_PKG

package sauria_base_tests_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_env_pkg::*;
    import sauria_base_cfg_seqs_pkg::*;
    
    `include "sauria_base_test.sv"
    `include "sauria_w_dma_base_test.sv"

endpackage

`endif //SAURIA_BASE_TESTS_PKG