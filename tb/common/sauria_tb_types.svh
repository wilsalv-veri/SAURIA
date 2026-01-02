

    typedef enum {AXI4_LITE, AXI4} sauria_axi_type_t;
    typedef enum {RD_ADDR, RD_DATA, WR_ADDR, WR_DATA,WR_RSP} sauria_axi_ch_type_t;

    typedef bit [CFG_AXI_ADDR_WIDTH-1:0]  sauria_axi4_lite_addr_t;
  
    typedef bit [CFG_AXI_DATA_WIDTH-1:0]  sauria_axi4_lite_data_t;
    typedef bit [CFG_AXI_BYTE_NUM-1:0]    sauria_axi4_lite_strobe_t;
   
    typedef bit [DATA_AXI_ID_WIDTH-1:0]   sauria_axi4_data_id_t;
    typedef bit [DATA_AXI_ADDR_WIDTH-1:0] sauria_axi4_data_addr_t;
      
    typedef bit [DATA_AXI_DATA_WIDTH-1:0] sauria_axi4_data_t;
    typedef bit [DATA_AXI_BYTE_NUM-1:0]   sauria_axi4_data_strobe_t;
  
   
    /// AXI Transaction Burst Type.
    typedef bit [1:0] sauria_axi_burst_t;
    /// AXI Transaction Response Type.
    typedef bit [1:0] sauria_axi_resp_t;
    /// AXI Transaction Cacheability Type.
    typedef bit [3:0] sauria_axi_cache_t;
    /// AXI Transaction Protection Type.
    typedef bit [2:0] sauria_axi_prot_t;
    /// AXI Transaction Quality of Service Type.
    typedef bit [3:0] sauria_axi_qos_t;
    /// AXI Transaction Region Type.
    typedef bit [3:0] sauria_axi_region_t;
    /// AXI Transaction Length Type.
    typedef bit [7:0] sauria_axi_len_t;
    /// AXI Transaction Size Type.
    typedef bit [2:0] sauria_axi_size_t;
    /// AXI5 Atomic Operation Type.
    typedef bit [5:0] sauria_axi_atop_t; // atomic operations
    /// AXI5 Non-Secure Address Identifier.
    typedef bit [3:0] sauria_axi_nsaid_t;

    //AXI4-LITE TYPES
    typedef struct packed{
        logic [CFG_AXI_ADDR_WIDTH-1:0]  araddr;
        axi_pkg::prot_t                 arprot;
        logic                           arvalid;
        logic                           arready;
    } sauria_axi4_lite_rd_addr_ch_t;

    typedef struct packed{
        logic [CFG_AXI_DATA_WIDTH-1:0]  rdata;
        axi_pkg::resp_t                 rresp;
        logic                           rvalid;
        logic                           rready;
    } sauria_axi4_lite_rd_data_ch_t;

    typedef struct packed{
        logic [CFG_AXI_ADDR_WIDTH-1:0]  awaddr;
        axi_pkg::prot_t                 awprot;
        logic                           awvalid;
        logic                           awready;
    } sauria_axi4_lite_wr_addr_ch_t;

    typedef struct packed{
        logic [CFG_AXI_DATA_WIDTH-1:0]  wdata;
        logic [CFG_AXI_BYTE_NUM-1:0]    wstrb;
        logic                           wvalid;
        logic                           wready;
    } sauria_axi4_lite_wr_data_ch_t;

    typedef struct packed{
        axi_pkg::resp_t                 bresp;
        logic                           bvalid;
        logic                           bready;
    } sauria_axi4_lite_wr_rsp_ch_t;

    //AXI4 TYPES
    typedef struct packed{
        logic [DATA_AXI_ID_WIDTH-1:0]   arid;
        logic [DATA_AXI_ADDR_WIDTH-1:0] araddr;
        axi_pkg::prot_t                 arprot;
        axi_pkg::burst_t                arburst;
        axi_pkg::len_t                  arlen;
        logic                           arvalid;
        axi_pkg::size_t                 arsize;
        logic                           arlock;
        axi_pkg::cache_t                arcache;
        axi_pkg::qos_t                  arqos;
        axi_pkg::region_t               arregion;
        logic                           arready;
    } sauria_axi4_rd_addr_ch_t;

    typedef struct packed{
        logic [DATA_AXI_ID_WIDTH-1:0]   rid;
        logic [DATA_AXI_DATA_WIDTH-1:0] rdata;
        axi_pkg::resp_t                 rresp;
        logic                           rvalid;
        logic                           rlast;
        logic                           rready;
    } sauria_axi4_rd_data_ch_t;

    typedef struct packed {
        logic [DATA_AXI_ID_WIDTH-1:0]   awid;
        logic [DATA_AXI_ADDR_WIDTH-1:0] awaddr;
        axi_pkg::prot_t                 awprot;
        axi_pkg::burst_t                awburst;
        axi_pkg::len_t                  awlen;
        logic                           awvalid;
        axi_pkg::size_t                 awsize;
        logic                           awlock;
        axi_pkg::cache_t                awcache;
        axi_pkg::qos_t                  awqos;
        axi_pkg::region_t               awregion;
        logic                           awready;
    } sauria_axi4_wr_addr_ch_t;

    typedef struct packed {
        logic [DATA_AXI_DATA_WIDTH-1:0] wdata;
        logic [DATA_AXI_BYTE_NUM-1:0]   wstrb;
        logic                           wlast;
        logic                           wvalid;
        logic                           wready;
    } sauria_axi4_wr_data_ch_t;

    typedef struct packed {
        logic [DATA_AXI_ID_WIDTH-1:0]  bid;
        axi_pkg::resp_t                bresp;
        logic                          bvalid;
        logic                          bready;
    } sauria_axi4_wr_rsp_ch_t;
