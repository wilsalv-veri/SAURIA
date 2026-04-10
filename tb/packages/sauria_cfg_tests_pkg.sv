`ifndef SAURIA_TESTS_PKG
`define SAURIA_TESTS_PKG

package sauria_cfg_tests_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_base_cfg_seqs_pkg::*;
    import sauria_cfg_seqs_pkg::*;
    import sauria_base_tests_pkg::*;

    `include "dma_tile_cfg_tests/sauria_single_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_x_dim_multi_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_y_dim_multi_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_c_dim_multi_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_k_dim_multi_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_all_dim_multi_tile_cfg_test.sv"
    `include "dma_tile_cfg_tests/sauria_rand_tile_dims_cfg_test.sv"
    `include "sauria_ifmaps_eq_array_cfg_test.sv"

endpackage

`endif //SAURIA_TESTS_PKG