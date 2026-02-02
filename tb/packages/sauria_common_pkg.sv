
`ifndef SAURIA_COMMON_PKG
`define SAURIA_COMMON_PKG
    
package sauria_common_pkg;
 
    parameter SAURIA_CLK_HALF_PERIOD = 1000; // in picoseconds (based on timescale)
    parameter SYSTEM_CLK_HALF_PERIOD = 333;
    
    parameter CFG_AXI_DATA_WIDTH     = 32;       // Configuration AXI4-Lite Slave data width
    parameter CFG_AXI_ADDR_WIDTH     = 32;       // Configuration AXI4-Lite Slave address width
    parameter DATA_AXI_DATA_WIDTH    = 1024;     // Data AXI4 Slave data width
    parameter DATA_AXI_ADDR_WIDTH    = 32;       // Data AXI4 Slave address width
    parameter DATA_AXI_ID_WIDTH      = 2;       // Data AXI4 Slave ID width
    
    parameter MEM_BASE_OFFSET        = sauria_addr_pkg::DMA_OFFSET;

    parameter  BYTE = 8;
    parameter  CFG_AXI_BYTE_NUM     = CFG_AXI_DATA_WIDTH/BYTE;
    parameter  DATA_AXI_BYTE_NUM    = DATA_AXI_DATA_WIDTH/BYTE;

    parameter N_DMA_CTRL_REGS       = 22;
    parameter N_SAURIA_CORE_REGS    = sauria_pkg::TOTAL_REGS_CON + sauria_pkg::TOTAL_REGS_ACT + sauria_pkg::TOTAL_REGS_WEI + sauria_pkg::TOTAL_REGS_OUT;
    parameter N_SAURIA_SS_REGS      = N_DMA_CTRL_REGS + N_SAURIA_CORE_REGS;
    parameter N_SEQ_REGS            = N_SAURIA_SS_REGS + 2;
    parameter DMA_CTRL_REGS_OFFSET  = 0;
    parameter SAURIA_SS_REGS_OFFSET = N_DMA_CTRL_REGS;

    parameter DF_CONTROLLER_CFG_CRs_START_IDX        = 18;
    parameter DF_CONTROLLER_CFG_CRs_END_IDX          = 21;
   
    parameter DMA_CONTROLLER_CFG_CRs_START_IDX       = 0;
    parameter DMA_CONTROLLER_CFG_CRs_END_IDX         = 17;
    
    parameter CORE_MAIN_CONTROLLER_CFG_CRs_START_IDX = 22;
    parameter CORE_MAIN_CONTROLLER_CFG_CRs_END_IDX   = 23;
    
    parameter CORE_IFMAPS_CFG_CRs_START_IDX          = 24;
    parameter CORE_IFMAPS_CFG_CRs_END_IDX            = 31;
    
    parameter CORE_WEIGHTS_CFG_CRs_START_IDX         = 32;
    parameter CORE_WEIGHTS_CFG_CRs_END_IDX           = 35;
    
    parameter CORE_PSUMS_CFG_CRs_START_IDX           = 36;
    parameter CORE_PSUMS_CFG_CRs_END_IDX             = 40;
    
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "sauria_tb_defines.svh"
    `include "sauria_tb_types.svh"
    
    `include "sauria_computation_params.sv"
    `include "sauria_axi_base_seq_items.sv"
    `include "sauria_tensor_mem_seq_item.sv"

    //AXI4_LITE_SEQ_ITEMS
    `include "sauria_axi4_lite_rd_addr_seq_item.sv"
    `include "sauria_axi4_lite_rd_data_seq_item.sv"
    `include "sauria_axi4_lite_wr_addr_seq_item.sv"
    `include "sauria_axi4_lite_wr_data_seq_item.sv"
    `include "sauria_axi4_lite_wr_rsp_seq_item.sv"
    `include "sauria_axi4_lite_wr_txn_seq_item.sv"

    //AXI4_SEQ_ITEMS
    `include "sauria_axi4_rd_addr_seq_item.sv"
    `include "sauria_axi4_rd_data_seq_item.sv"
    `include "sauria_axi4_wr_addr_seq_item.sv"
    `include "sauria_axi4_wr_data_seq_item.sv"
    `include "sauria_axi4_wr_rsp_seq_item.sv"
    `include "sauria_axi4_wr_txn_seq_item.sv"
    `include "sauria_axi4_rd_txn_seq_item.sv"

    `include "sauria_data_generator.sv"
    
    `include "sauria_cfg_cr_queue.sv"
    `include "sauria_axi_vseqr.sv"

    `include "sauria_axi4_lite_driver.sv"
    `include "sauria_axi4_lite_agent.sv"
   
    `include "sauria_axi4_driver.sv"
    `include "sauria_axi4_monitor.sv"
    `include "sauria_axi4_agent.sv"

    `include "sauria_axi4_lite_cfg_base_seq.sv"
    `include "sauria_axi4_lite_df_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_dma_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_main_controller_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_ifmaps_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_weights_cfg_base_seq.sv"
    `include "sauria_axi4_lite_core_psums_cfg_base_seq.sv"
    `include "sauria_axi4_lite_cfg_seq_lib.sv"
    `include "sauria_axi4_mem_base_seq.sv"
    `include "sauria_axi4_base_vseq.sv"
   
endpackage

`endif //SAURIA_COMMON_PKG

import sauria_common_pkg::*;