`ifndef SAURIA_TB_TOP_PKG_VH
`define SAURIA_TB_TOP_PKG_VH

package sauria_tb_top_pkg;

    logic                               i_sauria_clk;
    logic                               i_system_clk;
    
    logic                               i_sauria_rstn;
    logic                               i_system_rstn;

    logic  [CFG_AXI_ADDR_WIDTH-1:0]     i_cfg_axi_araddr;
    axi_pkg::prot_t                     i_cfg_axi_arprot;   
    logic                               i_cfg_axi_arvalid;
    logic                               o_cfg_axi_arready;

    logic  [CFG_AXI_DATA_WIDTH-1:0]     o_cfg_axi_rdata;
    axi_pkg::resp_t                     o_cfg_axi_rresp;
    logic                               o_cfg_axi_rvalid;
    logic                               i_cfg_axi_rready;

    logic  [CFG_AXI_ADDR_WIDTH-1:0]     i_cfg_axi_awaddr;
    axi_pkg::prot_t                     i_cfg_axi_awprot;
    logic                               i_cfg_axi_awvalid;
    logic                               o_cfg_axi_awready;


    logic  [CFG_AXI_DATA_WIDTH-1:0]     i_cfg_axi_wdata;
    logic  [CFG_AXI_BYTE_NUM-1:0]       i_cfg_axi_wstrb;
    logic                               i_cfg_axi_wvalid;
    logic                               o_cfg_axi_wready;

    axi_pkg::resp_t                     o_cfg_axi_bresp;
    logic                               o_cfg_axi_bvalid;
    logic                               i_cfg_axi_bready;

    // Data AXI4 MASTER interface
    logic  [DATA_AXI_ID_WIDTH-1:0]      o_dat_axi_arid;
    logic  [DATA_AXI_ADDR_WIDTH-1:0]    o_dat_axi_araddr;
    axi_pkg::prot_t                     o_dat_axi_arprot;
    axi_pkg::burst_t                    o_dat_axi_arburst;
    axi_pkg::len_t                      o_dat_axi_arlen;
    logic                               o_dat_axi_arvalid;
    axi_pkg::size_t                     o_dat_axi_arsize;
    logic                               o_dat_axi_arlock;
    axi_pkg::cache_t                    o_dat_axi_arcache;
    axi_pkg::qos_t                      o_dat_axi_arqos;
    axi_pkg::region_t                   o_dat_axi_arregion;
    
    logic                               i_dat_axi_arready;
    logic                               i_dat_axi_a;
    logic  [DATA_AXI_ID_WIDTH-1:0]      i_dat_axi_rid;
    logic  [DATA_AXI_DATA_WIDTH-1:0]    i_dat_axi_rdata;
    axi_pkg::resp_t                     i_dat_axi_rresp;
    logic                               i_dat_axi_rvalid;
    logic                               i_dat_axi_rlast;
    logic                               o_dat_axi_rready;

    logic  [DATA_AXI_ID_WIDTH-1:0]      o_dat_axi_awid;
    logic  [DATA_AXI_ADDR_WIDTH-1:0]    o_dat_axi_awaddr;
    axi_pkg::prot_t                     o_dat_axi_awprot;
    axi_pkg::burst_t                    o_dat_axi_awburst;
    axi_pkg::len_t                      o_dat_axi_awlen;
    logic                               o_dat_axi_awvalid;
    axi_pkg::size_t                     o_dat_axi_awsize;
    logic                               o_dat_axi_awlock;
    axi_pkg::cache_t                    o_dat_axi_awcache;
    axi_pkg::qos_t                      o_dat_axi_awqos;
    axi_pkg::region_t                   o_dat_axi_awregion;
    logic                               i_dat_axi_awready;

    logic  [DATA_AXI_DATA_WIDTH-1:0]    o_dat_axi_wdata;
    logic  [DATA_AXI_BYTE_NUM-1:0]      o_dat_axi_wstrb;
    logic                               o_dat_axi_wlast;
    logic                               o_dat_axi_wvalid;
    logic                               i_dat_axi_wready;

    logic  [DATA_AXI_ID_WIDTH-1:0]      i_dat_axi_bid;
    axi_pkg::resp_t                     i_dat_axi_bresp;
    logic                               i_dat_axi_bvalid;
    logic                               o_dat_axi_bready;

    // Control FSM Interrupt
    logic                               o_intr;

    // DMA Interrupt
    logic                               o_reader_dmaintr;      // DMA reader completion interrupt
    logic                               o_writer_dmaintr;       // DMA writer completion interrupt
    
    // SAURIA Interrupt
    logic                               o_sauriaintr;           // SAURIA core completion interrupt


    task init_sauria_subsystem_if(virtual sauria_subsystem_ifc sauria_subsystem_if);
        sauria_subsystem_if.i_sauria_clk = 0;
        sauria_subsystem_if.i_system_clk = 0;
        
        sauria_subsystem_if.i_sauria_rstn = 0;
        sauria_subsystem_if.i_system_rstn = 0;
    endtask

    task toggle_reset(virtual sauria_subsystem_ifc sauria_subsystem_if);
        fork 
            toggle_sauria_reset(sauria_subsystem_if);
            toggle_system_reset(sauria_subsystem_if);
        join
    endtask

    task toggle_sauria_reset(virtual sauria_subsystem_ifc sauria_subsystem_if);
        repeat(2) @ (posedge sauria_subsystem_if.i_sauria_clk) sauria_subsystem_if.i_sauria_rstn = ~ sauria_subsystem_if.i_sauria_rstn;
    endtask

    task toggle_system_reset(virtual sauria_subsystem_ifc sauria_subsystem_if);
        repeat(2) @ (posedge sauria_subsystem_if.i_system_clk) sauria_subsystem_if.i_system_rstn = ~ sauria_subsystem_if.i_system_rstn;
    endtask

endpackage

`endif //SAURIA_TB_TOP_PKG_VH
