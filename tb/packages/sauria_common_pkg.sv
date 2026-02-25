
`ifndef SAURIA_COMMON_PKG
`define SAURIA_COMMON_PKG
    
package sauria_common_pkg;
 
    parameter SAURIA_CLK_HALF_PERIOD = 1000; // in picoseconds (based on timescale)
    parameter SYSTEM_CLK_HALF_PERIOD = 333;
    
    parameter CFG_AXI_DATA_WIDTH     = 32;   // Configuration AXI4-Lite Slave data width
    parameter CFG_AXI_ADDR_WIDTH     = 32;   // Configuration AXI4-Lite Slave address width
    parameter DATA_AXI_DATA_WIDTH    = 1024; // Data AXI4 Slave data width
    parameter DATA_AXI_ADDR_WIDTH    = 32;   // Data AXI4 Slave address width
    parameter DATA_AXI_ID_WIDTH      = 2;    // Data AXI4 Slave ID width
    
    parameter CFG_BASE_OFFSET        = sauria_addr_pkg::CONTROLLER_OFFSET;
    parameter MEM_BASE_OFFSET        = sauria_addr_pkg::DMA_OFFSET;
    parameter CORE_CFG_BASE_OFFSET   = sauria_addr_pkg::SAURIA_OFFSET;

    parameter  BYTE = 8;
    parameter  CFG_AXI_BYTE_NUM      = CFG_AXI_DATA_WIDTH/BYTE;
    parameter  DATA_AXI_BYTE_NUM     = DATA_AXI_DATA_WIDTH/BYTE;

    parameter N_DMA_CTRL_REGS        = 22;
    parameter N_SAURIA_CORE_REGS     = sauria_pkg::TOTAL_REGS_CON + sauria_pkg::TOTAL_REGS_ACT + sauria_pkg::TOTAL_REGS_WEI + sauria_pkg::TOTAL_REGS_OUT;
    parameter N_SAURIA_SS_REGS       = N_DMA_CTRL_REGS + N_SAURIA_CORE_REGS;
    parameter N_SEQ_REGS             = N_SAURIA_SS_REGS + 1;
    parameter DMA_CTRL_REGS_OFFSET   = 0;
    parameter SAURIA_SS_REGS_OFFSET  = N_DMA_CTRL_REGS;

    parameter START_SRAMA_MEM_ADDR   = 32'h7000_0000;
    parameter START_SRAMB_MEM_ADDR   = 32'h8000_0000;
    parameter START_SRAMC_MEM_ADDR   = 32'h9000_0000;

    parameter START_SRAMA_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMA_OFFSET;
    parameter START_SRAMB_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMB_OFFSET;
    parameter START_SRAMC_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMC_OFFSET;
    
    parameter DF_CONTROLLER_CFG_CRs_START_IDX        = 18;
    parameter DF_CONTROLLER_CFG_CRs_END_IDX          = 21;
   
    parameter DMA_CONTROLLER_CFG_CRs_START_IDX       = 0;
    parameter DMA_CONTROLLER_CFG_CRs_END_IDX         = 17;
    
    parameter CORE_MAIN_CONTROLLER_CFG_CRs_START_IDX = 22;
    parameter CORE_MAIN_CONTROLLER_CFG_CRs_END_IDX   = 23;
    
    parameter CORE_IFMAPS_CFG_CRs_START_IDX          = 24;
    parameter CORE_IFMAPS_CFG_CRs_END_IDX            = 32;
    
    parameter CORE_WEIGHTS_CFG_CRs_START_IDX         = 33;
    parameter CORE_WEIGHTS_CFG_CRs_END_IDX           = 36;
    
    parameter CORE_PSUMS_CFG_CRs_START_IDX           = 37;
    parameter CORE_PSUMS_CFG_CRs_END_IDX             = 41;
    
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

    `include "sauria_cfg_cr_queue.sv"
    `include "sauria_axi_vseqr.sv"
    
endpackage

`endif //SAURIA_COMMON_PKG

