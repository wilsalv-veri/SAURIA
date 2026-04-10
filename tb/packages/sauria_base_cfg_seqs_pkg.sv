`ifndef SAURIA_BASE_CFG_SEQS_PKG
`define SAURIA_BASE_CFG_SEQS_PKG

package sauria_base_cfg_seqs_pkg;

    import uvm_pkg::*;
    import sauria_pkg::*;
    import sauria_common_pkg::*;
    import sauria_env_pkg::*;
    import sauria_cfg_regs_pkg::*;
    
    function sauria_axi4_lite_addr_t get_cfg_addr_from_idx(int cfg_cr_idx);
        return sauria_axi4_lite_addr_t'('h10 + cfg_cr_idx*4);
    endfunction

    parameter SINGLE_TILE_DIM_VAL    = 0;
    parameter MIN_MULTI_TILE_DIM_VAL = 1;
    parameter MAX_MULTI_TILE_DIM_VAL = 4; 

    parameter MIN_COMP_LEN           = 1;
    parameter MAX_COMP_LEN           = 32;

    parameter MIN_MULTIPLE           = 1;
    parameter MAX_MULTIPLE           = 8;
    
    `include "sauria_cfg_seq_params.sv"
    `include "sauria_axi4_lite_cfg_base_seq.sv"
    `include "sauria_axi4_lite_df_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_dma_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_main_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_ifmaps_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_weights_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_psums_cfg_base_seq.sv"
    `include "sauria_axi4_lite_ctrl_status_cfg_base_seq.sv"
    `include "sauria_axi4_lite_cfg_seq_lib.sv"
    `include "sauria_axi4_mem_base_seq.sv"
    `include "sauria_axi4_base_vseq.sv"
   
endpackage

`endif //SAURIA_BASE_CFG_SEQS_PKG