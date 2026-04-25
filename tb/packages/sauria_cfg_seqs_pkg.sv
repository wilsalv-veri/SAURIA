`ifndef SAURIA_CFG_SEQS_PKG
`define SAURIA_CFG_SEQS_PKG

package sauria_cfg_seqs_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;
    import sauria_base_cfg_seqs_pkg::*;

    //DF Controller Seqs
    `include "sauria_rand_df_controller_cfg_seq.sv"
    `include "sauria_stand_alone_OFF_df_controller_cfg_seq.sv"

    //Core Main Controller Seqs
    `include "sauria_rand_core_main_controller_cfg_seq.sv"

    //Core IFMAPS Seqs
    `include "sauria_rand_core_ifmaps_cfg_seq.sv"

    //Core Weights Seqs
    `include "sauria_rand_core_weights_cfg_seq.sv"

    //Core PSUMS Seqs
    `include "sauria_rand_core_psums_cfg_seq.sv"

    //DMA Controller Seqs

    //Tile Seqs
    `include "dma_tile_cfg_seqs/sauria_single_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_x_dim_multi_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_y_dim_multi_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_c_dim_multi_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_k_dim_multi_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_all_dim_multi_tile_dma_cfg_seq.sv"
    `include "dma_tile_cfg_seqs/sauria_rand_tile_dims_dma_cfg_seq.sv"
    
    `include "sauria_ifmaps_eq_array_dma_ctrl_seq.sv"

endpackage
`endif //SAURIA_CFG_SEQS_PKG