
`ifndef SAURIA_COMMON_PKG
`define SAURIA_COMMON_PKG
    
package sauria_common_pkg;
 
    import sauria_pkg::*;
    import uvm_pkg::*;
    `include "uvm_macros.svh"

    parameter ARITHMETIC             = `ARITHMETIC;
    parameter INT_ARITHMETIC         = !ARITHMETIC;
    parameter FP_ARITHMETIC          = ARITHMETIC;

    parameter COLS_ACTIVE_SIZE       = sauria_pkg::X;
    parameter ROWS_ACTIVE_SIZE       = sauria_pkg::Y; 
   
    parameter  BYTE = 8;
    
    parameter SAURIA_CLK_HALF_PERIOD = 1000; // in picoseconds (based on timescale)
    parameter SYSTEM_CLK_HALF_PERIOD = SAURIA_CLK_HALF_PERIOD / 3;
    
    parameter CFG_AXI_DATA_WIDTH     = 32;   // Configuration AXI4-Lite Slave data width
    parameter CFG_AXI_ADDR_WIDTH     = 32;   // Configuration AXI4-Lite Slave address width
    parameter DATA_AXI_DATA_WIDTH    = 1024; // Data AXI4 Slave data width
    parameter DATA_AXI_ADDR_WIDTH    = 32;   // Data AXI4 Slave address width
    parameter DATA_AXI_ID_WIDTH      = 2;    // Data AXI4 Slave ID width

    parameter CFG_BASE_OFFSET        = sauria_addr_pkg::CONTROLLER_OFFSET;
    parameter MEM_BASE_OFFSET        = sauria_addr_pkg::DMA_OFFSET;
    parameter CORE_CFG_BASE_OFFSET   = sauria_addr_pkg::SAURIA_OFFSET;

    parameter  CFG_AXI_BYTE_NUM      = CFG_AXI_DATA_WIDTH/BYTE;
    parameter  DATA_AXI_BYTE_NUM     = DATA_AXI_DATA_WIDTH/BYTE;
    parameter  DATA_AXI_ADDR_MASK    = 32'hFFFF_FF80;

    parameter N_DMA_CTRL_REGS        = 22;
    parameter N_SAURIA_CORE_REGS     = sauria_pkg::TOTAL_REGS_CON + sauria_pkg::TOTAL_REGS_ACT + sauria_pkg::TOTAL_REGS_WEI + sauria_pkg::TOTAL_REGS_OUT;
    parameter N_SAURIA_SS_REGS       = N_DMA_CTRL_REGS + N_SAURIA_CORE_REGS;
    parameter N_SEQ_REGS             = N_SAURIA_SS_REGS + 1;
    parameter DMA_CTRL_REGS_OFFSET   = 0;
    parameter SAURIA_SS_REGS_OFFSET  = N_DMA_CTRL_REGS;

    parameter ACT_TILE_DIM_SIZE      = sauria_pkg::ACT_IDX_W;
    parameter WEI_TILE_DIM_SIZE      = sauria_pkg::WEI_IDX_W;
    parameter PSUMS_TILE_DIM_SIZE    = sauria_pkg::OUT_IDX_W;

    parameter START_SRAMA_MEM_ADDR   = 32'h7000_0000;
    parameter START_SRAMB_MEM_ADDR   = 32'h8000_0000;
    parameter START_SRAMC_MEM_ADDR   = 32'h9000_0000;

    parameter START_SRAMA_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMA_OFFSET;
    parameter START_SRAMB_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMB_OFFSET;
    parameter START_SRAMC_LOCAL_ADDR = sauria_addr_pkg::SAURIA_DMA_OFFSET + sauria_addr_pkg::SRAMC_OFFSET;
    
    parameter SAURIA_REG_SIZE = 32;
    parameter SAURIA_REG_SIZE_BYTES  = SAURIA_REG_SIZE/BYTE;
    
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
    
    parameter PSUMS_SHIFT_REG_BUFF_W = OC_W * Y;

    `include "sauria_tb_defines.svh"
    `include "sauria_tb_types.svh"
    `include "sauria_plusarg_utils.sv"

    parameter fp16_data_t FP16_POS_ZERO  = 16'h0000;
    parameter fp16_data_t FP16_NEG_ZERO  = 16'h8000;
    parameter fp16_data_t FP16_ONE       = 16'h3C00;
    parameter fp16_data_t FP16_NEG_ONE   = 16'hBC00;
    parameter fp16_data_t FP16_TWO       = 16'h4000;
    parameter fp16_data_t FP16_HALF      = 16'h3800;
    parameter fp16_data_t FP16_MIN_NORM  = 16'h0400;
    parameter fp16_data_t FP16_MAX_SUB   = 16'h03FF;
    parameter fp16_data_t FP16_MIN_SUB   = 16'h0001;
    parameter fp16_data_t FP16_MAX_FIN   = 16'h7BFF;
    parameter fp16_data_t FP16_POS_INF   = 16'h7C00;
    parameter fp16_data_t FP16_NEG_INF   = 16'hFC00;
    parameter fp16_data_t FP16_QNAN      = 16'h7E00;

    parameter IFMAPS_DATA_MODE  = INT_ARITHMETIC ? SING_NIB_INCR_PATTERN : FP_ONE_W_FRAC_COMP;
    parameter WEIGHTS_DATA_MODE = INT_ARITHMETIC ? SING_NIB_INCR_PATTERN : FP_NEG_ONE;
    parameter PSUMS_DATA_MODE   = INT_ARITHMETIC ? ALL_TWOS              : FP_ONE;
    
    parameter CS_FIRST_IDX = arr_row_data_t'('h8000);
    parameter CS_LAST_IDX  = arr_row_data_t'('h0001);
   
    `include "sauria_computation_params.sv"
    `include "sauria_axi_base_seq_items.sv"
    `include "sauria_tensor_mem_seq_item.sv"

    //AXI4_LITE_SEQ_ITEMS
    `include "sauria_axi4_lite_rd_addr_seq_item.sv"
    `include "sauria_axi4_lite_rd_data_seq_item.sv"
    `include "sauria_axi4_lite_rd_txn_seq_item.sv"
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

    //CORE_SEQ_ITEMS
    `include "sauria_main_controller_seq_item.sv"
    `include "sauria_ifmaps_feeder_seq_item.sv"
    `include "sauria_weights_feeder_seq_item.sv"
    `include "sauria_systolic_array_seq_item.sv"
    `include "sauria_psums_mgr_seq_item.sv"
    
endpackage

`endif //SAURIA_COMMON_PKG

