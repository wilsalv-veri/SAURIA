`ifndef SAURIA_BASE_CFG_SEQS_PKG
`define SAURIA_BASE_CFG_SEQS_PKG

package sauria_base_cfg_seqs_pkg;

    import uvm_pkg::*;
    import sauria_pkg::*;
    import sauria_common_pkg::*;
    import sauria_env_pkg::*;
    import sauria_cfg_regs_pkg::*;
    
    parameter CFG_CRS_BASE_OFFSET = 'h10;

    function sauria_axi4_lite_addr_t get_cfg_addr_from_idx(int cfg_cr_idx);
        return sauria_axi4_lite_addr_t'(CFG_CRS_BASE_OFFSET + cfg_cr_idx*CFG_AXI_BYTE_NUM);
    endfunction

    parameter SINGLE_TILE_DIM_VAL    = 0;
    
    //FIXME: wilsalv
    //parameter MIN_MULTI_TILE_DIM_VAL = 1;
    parameter MIN_MULTI_TILE_DIM_VAL = 4;
    
    
    parameter MAX_MULTI_TILE_DIM_VAL = 16; 

    parameter MIN_COMP_LEN           = 1;
    parameter MAX_COMP_LEN           = 32;

    parameter MIN_MULTIPLE           = 1;
    parameter MAX_MULTIPLE           = 16;
    
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