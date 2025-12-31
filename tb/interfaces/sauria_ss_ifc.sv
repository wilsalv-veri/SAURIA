import sauria_tb_top_pkg::*;

interface SAURIA_ss_ifc;

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


    //***************************************************** */
    modport master (
        // SAURIA Clk & RST @500M
	    input i_sauria_clk,
	    input i_sauria_rstn,

        // System Clk & RST @1500M
	    input i_system_clk,
	    input i_system_rstn,

        // Configuration AXI4-Lite SLAVE interface
        input  i_cfg_axi_araddr,
        input  i_cfg_axi_arprot,
        input  i_cfg_axi_arvalid,
        output o_cfg_axi_arready,

        output o_cfg_axi_rdata,
        output o_cfg_axi_rresp,
        output o_cfg_axi_rvalid,
        input  i_cfg_axi_rready,

        input  i_cfg_axi_awaddr,
        input  i_cfg_axi_awprot,
        input  i_cfg_axi_awvalid,
        output o_cfg_axi_awready,

        input  i_cfg_axi_wdata,
        input  i_cfg_axi_wstrb,
        input  i_cfg_axi_wvalid,
        output o_cfg_axi_wready,

        output o_cfg_axi_bresp,
        output o_cfg_axi_bvalid,
        input  i_cfg_axi_bready,

        // Data AXI4 MASTER interface
        output o_dat_axi_arid,
        output o_dat_axi_araddr,
        output o_dat_axi_arprot,
        output o_dat_axi_arburst,
        output o_dat_axi_arlen,
        output o_dat_axi_arvalid,
        output o_dat_axi_arsize,
        output o_dat_axi_arlock,
        output o_dat_axi_arcache,
        output o_dat_axi_arqos,
        output o_dat_axi_arregion,
    
        input  i_dat_axi_arready,
        input  i_dat_axi_rid,
        input  i_dat_axi_rdata,
        input  i_dat_axi_rresp,
        input  i_dat_axi_rvalid,
        input  i_dat_axi_rlast,
        output o_dat_axi_rready,

        output o_dat_axi_awid,
        output o_dat_axi_awaddr,
        output o_dat_axi_awprot,
        output o_dat_axi_awburst,
        output o_dat_axi_awlen,
        output o_dat_axi_awvalid,
        output o_dat_axi_awsize,
        output o_dat_axi_awlock,
        output o_dat_axi_awcache,
        output o_dat_axi_awqos,
        output o_dat_axi_awregion,
        input  i_dat_axi_awready,

        output o_dat_axi_wdata,
        output o_dat_axi_wstrb,
        output o_dat_axi_wlast,
        output o_dat_axi_wvalid,
        input  i_dat_axi_wready,

        input  i_dat_axi_bid,
        input  i_dat_axi_bresp,
        input  i_dat_axi_bvalid,
        output o_dat_axi_bready,

        // Control FSM Interrupt
        output o_intr,

        // DMA Interrupt
        output o_reader_dmaintr,       // DMA reader completion interrupt
        output o_writer_dmaintr,       // DMA writer completion interrupt
    
        // SAURIA Interrupt
        output o_sauriaintr            // SAURIA core completion interrupt

    );

endinterface