`ifndef SAURIA_CFG_SEQS_PKG
`define SAURIA_CFG_SEQS_PKG

package sauria_cfg_seqs_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_base_cfg_seqs_pkg::*;

    //DF Controller Seqs
    `include "sauria_rand_df_controller_cfg_seq.sv"
    `include "sauria_stand_alone_OFF_df_controller_cfg_seq.sv"

    //DMA Controller Seqs
    `include "sauria_ifmaps_eq_array_dma_ctrl_seq.sv"

endpackage
`endif //SAURIA_CFG_SEQS_PKG