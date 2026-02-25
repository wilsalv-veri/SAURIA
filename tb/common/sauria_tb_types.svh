

    typedef enum {AXI4_LITE, AXI4} sauria_axi_type_t;
    typedef enum {RD_ADDR, RD_DATA, WR_ADDR, WR_DATA,WR_RSP} sauria_axi_ch_type_t;
    typedef enum {RD_TXN, WR_TXN} sauria_axi_txn_type_t;
    typedef enum {IFMAPS, WEIGHTS, PSUMS} sauria_tensor_type_t;

    typedef bit [CFG_AXI_ADDR_WIDTH-1:0]  sauria_axi4_lite_addr_t;
    typedef bit [DATA_AXI_ADDR_WIDTH-1:0] sauria_axi4_addr_t;

    typedef bit [CFG_AXI_DATA_WIDTH-1:0]  sauria_axi4_lite_data_t;
    typedef bit [DATA_AXI_DATA_WIDTH-1:0] sauria_axi4_data_t;

    typedef bit [`IA_W-1:0]               sauria_ifmaps_elem_data_t;
    typedef bit [`IB_W-1:0]               sauria_weights_elem_data_t;
    typedef bit [`OC_W-1:0]               sauria_psums_elem_data_t;

    typedef bit [CFG_AXI_BYTE_NUM-1:0]    sauria_axi4_lite_strobe_t;
    typedef bit [DATA_AXI_BYTE_NUM-1:0]   sauria_axi4_strobe_t;
   
    typedef bit [DATA_AXI_ID_WIDTH-1:0]   sauria_axi4_id_t;
      
    /// AXI Transaction Burst Type.
    typedef bit [1:0] sauria_axi_burst_t;
    /// AXI Transaction Response Type.
    typedef bit [1:0] sauria_axi_resp_t;
    /// AXI Transaction Cacheability Type.
    typedef bit [3:0] sauria_axi_cache_t;
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

    typedef enum {DATA=0, INSTR=1} sauria_data_type_t;
    typedef enum {OKAY=sauria_axi_resp_t'('h0), EXOKAY=sauria_axi_resp_t'('h1), 
                SLVERR=sauria_axi_resp_t'('h2), DECERR=sauria_axi_resp_t'('h3)} 
                sauria_axi_resp_type_t;
    
    /// AXI Transaction Protection Type.
    typedef struct packed{
        bit data_type_access;
        bit secure_access;
        bit priviliged_access;
    } sauria_axi_prot_t;

    //AXI Transaction Burst Type (2 bits)
    //Encoding for sauria_axi_burst_t
    typedef enum bit [1:0] {
        FIXED = 2'h0, // All transfers use the same address
        INCR  = 2'h1, // Address increments sequentially (default)
        WRAP  = 2'h2  // Address wraps around upon reaching the boundary
        // 2'h3 is reserved
    } sauria_axi_burst_e;

    //AXI Transaction Cacheability Type (4 bits)
    //Encoding for sauria_axi_cache_t (ARCACHE, AWCACHE)
    typedef enum bit [3:0] {
        // b00xx: Bufferable/Non-cacheable
        NON_CACHEABLE_MODIFIABLE  = 4'h0,
        NON_CACHEABLE_NON_MODIFIABLE = 4'h1,
        // b01xx: Cacheable, can be allocated but not evicted
        // b10xx: Cacheable, cannot be allocated but can be evicted
        // b11xx: Cacheable, can be allocated and evicted
        // Use the specific bit meanings (e.g., Bufferable, Cacheable, Read-Allocate, Write-Allocate)
        // Common examples:
        //DEVICE_NON_BUFFERABLE = 4'h0,
        NORMAL_NON_CACHEABLE  = 4'h3,
        NORMAL_WRITE_BACK     = 4'hF // A common highly-cached setting
    } sauria_axi_cache_e;

    //AXI Transaction Quality of Service Type (4 bits)
    //Encoding for sauria_axi_qos_t (ARQOS, AWQOS)
    //4'h0 is the lowest priority; 4'hF is the highest
    typedef enum bit [3:0] {
        LOWEST_QOS  = 4'h0,
        MEDIUM_QOS  = 4'h8,
        HIGHEST_QOS = 4'hF
    } sauria_axi_qos_e;

    //AXI Transaction Region Type (4 bits)
    // Encoding for sauria_axi_region_t (ARREGION, AWREGION)
    // Used to provide memory region hints; 4'h0-4'hF are distinct regions
    typedef enum bit [3:0] {
        REGION_0 = 4'h0,
        REGION_1 = 4'h1,
        REGION_F = 4'hF
    } sauria_axi_region_e;

    //AXI Transaction Size Type (3 bits)
    //Encoding for sauria_axi_size_t (ARSIZE, AWSIZE) - Size of each transfer
    typedef enum bit [2:0] {
        SIZE_1_BYTE   = 3'h0, // 2^0 = 1 Byte
        SIZE_2_BYTES  = 3'h1, // 2^1 = 2 Bytes
        SIZE_4_BYTES  = 3'h2, // 2^2 = 4 Bytes
        SIZE_8_BYTES  = 3'h3, // 2^3 = 8 Bytes
        SIZE_16_BYTES = 3'h4, // 2^4 = 16 Bytes
        SIZE_32_BYTES = 3'h5, // 2^5 = 32 Bytes
        SIZE_64_BYTES = 3'h6, // 2^6 = 64 Bytes
        SIZE_128_BYTES= 3'h7  // 2^7 = 128 Bytes (Max transfer size)
    } sauria_axi_size_e;


    //AXI4 Atomic Operation Type (6 bits)
    //Encoding for sauria_axi_atop_t (ARATOP, AWATOP)
    typedef enum bit [5:0] {
        ATOP_NONE         = 6'h00,
        ATOP_LOAD         = 6'h01,
        ATOP_STORE        = 6'h02,
        ATOP_SWAP         = 6'h03,
        ATOP_COMPARE_SWAP = 6'h04
        // ... other standard atomic ops (add, logical, etc.)
    } sauria_axi_atop_e;

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


    typedef enum bit [1:0] {
        DMA_BRING_A,
        DMA_BRING_B,
        DMA_BRING_C,
        DMA_SEND_C
    } df_ctrl_substate_t;

    typedef enum {RAND, ADDR_AS_DATA, BAD_PATTERN, INCR_PATTERN} data_gen_mode_t;

