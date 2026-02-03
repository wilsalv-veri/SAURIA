`ifndef SAURIA_TESTS_PKG
`define SAURIA_TESTS_PKG

package sauria_cfg_tests_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_base_cfg_seqs_pkg::*;
    import sauria_cfg_seqs_pkg::*;
    import sauria_base_tests_pkg::*;

    `include "sauria_ifmaps_eq_array_cfg_test.sv"

endpackage

`endif //SAURIA_TESTS_PKG