
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
    
    localparam  BYTE = 8;
    localparam  CFG_AXI_BYTE_NUM     = CFG_AXI_DATA_WIDTH/BYTE;
    localparam  DATA_AXI_BYTE_NUM    = DATA_AXI_DATA_WIDTH/BYTE;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    `include "sauria_tb_types.svh"
    
    `include "sauria_axi_base_seq_items.sv"

    //AXI4_LITE_SEQ_ITEMS
    `include "sauria_axi4_lite_rd_addr_seq_item.sv"
    `include "sauria_axi4_lite_rd_data_seq_item.sv"
    `include "sauria_axi4_lite_wr_addr_seq_item.sv"
    `include "sauria_axi4_lite_wr_data_seq_item.sv"
    `include "sauria_axi4_lite_wr_rsp_seq_item.sv"

    //AXI4_SEQ_ITEMS
    `include "sauria_axi4_rd_addr_seq_item.sv"
    `include "sauria_axi4_rd_data_seq_item.sv"
    `include "sauria_axi4_wr_addr_seq_item.sv"
    `include "sauria_axi4_wr_data_seq_item.sv"
    `include "sauria_axi4_wr_rsp_seq_item.sv"

    `include "sauria_axi4_lite_driver.sv"
    `include "sauria_axi4_lite_agent.sv"
   
    //`include "axi4_lite_driver.sv"
    `include "sauria_axi4_agent.sv"

    `include "sauria_env.sv"

    `include "sauria_axi4_lite_base_seq.sv"
  
endpackage

`endif //SAURIA_COMMON_PKG

import sauria_common_pkg::*;