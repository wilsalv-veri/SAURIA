

    typedef enum {AXI4_LITE, AXI4} sauria_axi_type_t;
    typedef enum {RD_ADDR, RD_DATA, WR_ADDR, WR_DATA,WR_RSP} sauria_axi_ch_type_t;
    typedef enum {RD_TXN, WR_TXN} sauria_axi_txn_type_t;
    typedef enum {IFMAPS, WEIGHTS, PSUMS} sauria_tensor_type_t;

    typedef bit [CFG_AXI_ADDR_WIDTH-1:0]  sauria_axi4_lite_addr_t;
    typedef bit [DATA_AXI_ADDR_WIDTH-1:0] sauria_axi4_addr_t;

    typedef bit [CFG_AXI_DATA_WIDTH-1:0]  sauria_axi4_lite_data_t;
    typedef bit [DATA_AXI_DATA_WIDTH-1:0] sauria_axi4_data_t;

    typedef enum bit [1:0] {GEMM_OPERAND_A, GEMM_OPERAND_B, GEMM_OPERAND_C} gemm_tensor_operand_t;
    typedef enum bit {GEMM_ACCESS_READ, GEMM_ACCESS_WRITE} gemm_access_dir_t;

    typedef struct {
        sauria_axi4_lite_data_t total_m;
        sauria_axi4_lite_data_t total_k;
        sauria_axi4_lite_data_t total_n;
        sauria_axi4_lite_data_t tile_m_count;
        sauria_axi4_lite_data_t tile_k_count;
        sauria_axi4_lite_data_t tile_n_count;
        sauria_axi4_lite_data_t a_m_per_tile;
        sauria_axi4_lite_data_t a_k_per_tile;
        sauria_axi4_lite_data_t b_k_per_tile;
        sauria_axi4_lite_data_t b_n_per_tile;
        sauria_axi4_lite_data_t c_m_per_tile;
        sauria_axi4_lite_data_t c_n_per_tile;
    } gemm_problem_shape_t;

    typedef struct {
        bit                     valid;
        gemm_tensor_operand_t   operand;
        gemm_access_dir_t       access_dir;
        sauria_axi4_lite_data_t m_tile_idx;
        sauria_axi4_lite_data_t k_tile_idx;
        sauria_axi4_lite_data_t n_tile_idx;
        sauria_axi4_lite_data_t m_block_idx;
        sauria_axi4_lite_data_t k_block_idx;
        sauria_axi4_lite_data_t n_block_idx;
        sauria_axi4_lite_data_t contiguous_span;
        bit                     requires_existing_c;
        bit                     final_c_write;
    } gemm_tensor_access_event_t;

    typedef struct {
        bit                valid;
        sauria_tensor_type_t tensor;
        gemm_access_dir_t  access_dir;
        sauria_axi4_lite_data_t m_tile_idx;
        sauria_axi4_lite_data_t k_tile_idx;
        sauria_axi4_lite_data_t n_tile_idx;
        sauria_axi4_lite_data_t m_block_idx;
        sauria_axi4_lite_data_t k_block_idx;
        sauria_axi4_lite_data_t n_block_idx;
        int                sauria_tile_idx;
        int                reported_psums_tile_idx;
        sauria_axi4_addr_t intra_tile_offset;
        sauria_axi4_addr_t tile_offset;
        sauria_axi4_addr_t elem_byte_offset;
        sauria_axi4_addr_t row_addr;
        bit                final_c_write;
    } gemm_sauria_addr_map_t;

    typedef bit [sauria_pkg::IA_W-1:0]    sauria_ifmaps_elem_data_t;
    typedef bit [sauria_pkg::IB_W-1:0]    sauria_weights_elem_data_t;
    typedef bit [sauria_pkg::OC_W-1:0]    sauria_psums_elem_data_t;
    typedef sauria_psums_elem_data_t      sauria_fp_elem_data_t; //In FP case IFMAPS, WEIGHTS, and PSUMS are same length

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

    typedef enum {RAND_INT_DATA_MODE, RAND_INT, ADDR_AS_DATA, BAD_PATTERN, 
                INCR_PATTERN, SING_NIB_INCR_PATTERN, 
                ALL_ONES, ALL_TWOS} int_data_gen_mode_t;
        
    typedef enum {RAND_FP_DATA_MODE, RAND_FP, FP_ONE, FP_ONE_W_FRAC_COMP, FP_NEG_ONE,         
                FP_HALF, FP_TWO} fp_data_gen_mode_t;

    typedef bit [sauria_pkg::ADRA_W-1:0]                                      srama_addr_t;
    typedef bit [sauria_pkg::SRAMA_W-1:0]                                     srama_data_t;
    typedef bit [0:sauria_pkg::Y-1][sauria_pkg::IA_W-1:0]                     a_arr_data_t;

    typedef bit [sauria_pkg::ADRB_W-1:0]                                      sramb_addr_t;
    typedef bit [sauria_pkg::SRAMB_W-1:0]                                     sramb_data_t;
    typedef bit [0:sauria_pkg::X-1][sauria_pkg::IB_W-1:0]                     b_arr_data_t;

    typedef bit [sauria_pkg::ADRC_W-1:0]                                      sramc_addr_t;
    typedef bit [sauria_pkg::SRAMC_W-1:0]                                     sramc_data_t;
    typedef bit [0:sauria_pkg::SRAMC_N-1]                                     sramc_data_mask_t;
    typedef bit [0:sauria_pkg::Y-1][sauria_pkg::OC_W-1:0]                     scan_chain_data_t;
    typedef bit [sauria_pkg::Y-1:0][sauria_pkg::OC_W-1:0]                     scan_chain_data_rev_t;
    typedef scan_chain_data_t                                                 scan_chain_data_q_t [$];

    typedef bit [sauria_pkg::Y-1:0][sauria_pkg::X-1:0][sauria_pkg::OC_W-1:0]  arr_psum_reg_t ;
    typedef bit [sauria_pkg::Y-1:0][sauria_pkg::X-1:0]                        arr_cswitch_en_t ;

    typedef bit [0:sauria_pkg::Y-1]                                           arr_col_data_t;
    typedef bit [sauria_pkg::Y-1:0]                                           arr_col_data_rev_t;
    
    typedef bit [0:sauria_pkg::X-1]                                           arr_row_data_t;
    typedef bit [sauria_pkg::X-1:0]                                           arr_row_data_rev_t;
    
    typedef bit [sauria_pkg::TH_W-1:0]                                        threshold_t;


    typedef struct {
        sauria_axi4_lite_data_t ifmaps_c_step;
        sauria_axi4_lite_data_t ifmaps_C;

        sauria_axi4_lite_data_t ifmaps_x_step;
        sauria_axi4_lite_data_t ifmaps_X;
        
        sauria_axi4_lite_data_t ifmaps_y_step;
        sauria_axi4_lite_data_t ifmaps_Y;

    } ifmaps_tile_params_t;

    typedef struct {
        sauria_axi4_lite_data_t tile_ifmaps_x_step;
        sauria_axi4_lite_data_t tile_ifmaps_X;

        sauria_axi4_lite_data_t tile_ifmaps_y_step;
        sauria_axi4_lite_data_t tile_ifmaps_Y;
        
        sauria_axi4_lite_data_t tile_ifmaps_c_step;
        sauria_axi4_lite_data_t tile_ifmaps_C;
        
    } ifmaps_tensor_params_t;

    typedef struct {
        ifmaps_tile_params_t   tile_params;
        ifmaps_tensor_params_t tensor_params;

    } ifmaps_params_t;

    typedef struct {

        sauria_axi4_lite_data_t weights_w_step;
        sauria_axi4_lite_data_t weights_W;
        sauria_axi4_lite_data_t weights_C;

        sauria_axi4_lite_data_t weights_k_step;
        sauria_axi4_lite_data_t weights_K;
        
    } weights_tile_params_t;

    typedef struct {

        sauria_axi4_lite_data_t tile_weights_c_step;
        sauria_axi4_lite_data_t tile_weights_C;
        
        sauria_axi4_lite_data_t tile_weights_k_step;
        sauria_axi4_lite_data_t tile_weights_K;
        
    } weights_tensor_params_t;

    typedef struct {

        weights_tile_params_t   tile_params;
        weights_tensor_params_t tensor_params;

    } weights_params_t;

    
    //Inter-Tile
    
    typedef struct {

        sauria_axi4_lite_data_t psums_K;    
        sauria_axi4_lite_data_t psums_Y;
        sauria_axi4_lite_data_t psums_X;

        sauria_axi4_lite_data_t psums_ck_step;
        sauria_axi4_lite_data_t psums_CK;     
        
        sauria_axi4_lite_data_t psums_cx_step;
        sauria_axi4_lite_data_t psums_CX;    
        
    } psums_tile_params_t;

    typedef struct {

        sauria_axi4_lite_data_t tile_psums_cy_step;
        sauria_axi4_lite_data_t tile_psums_CY;    
        
        sauria_axi4_lite_data_t tile_psums_ck_step;
        sauria_axi4_lite_data_t tile_psums_CK;    
        
    } psums_tensor_params_t;

    typedef struct {

        psums_tile_params_t   tile_params;
        psums_tensor_params_t tensor_params;

    } psums_params_t;

    typedef scan_chain_data_t psums_shift_reg_snapshot_t [sauria_pkg::X];

    typedef struct {
        bit          addr_check_valid;
        bit          addr_mismatch;
        sramc_addr_t exp_addr;
    } psums_mgr_sramc_read_result_t;

    typedef struct {
        bit          addr_mismatch;
        sramc_addr_t exp_addr;
        bit          shift_reg_data_empty;
        bit          data_valid;
        sramc_data_t exp_wdata;
    } psums_mgr_sramc_write_result_t;

    typedef struct {
        bit               valid_preload_check;
        scan_chain_data_t exp_preload_data;
    } psums_mgr_preload_result_t;

    typedef struct {
        bit                         valid_snapshot;
        psums_shift_reg_snapshot_t  exp_shift_reg;
    } psums_mgr_shift_reg_result_t;

    typedef struct {
        bit               valid_scan_chain_out;
        int               scan_chain_out_col_idx;
        scan_chain_data_t exp_scan_chain_out_col;
        bit               valid_psum_reserve_reg_snapshot;
        arr_psum_reg_t    exp_arr_psum_reserve_reg;
    } systolic_array_scan_chain_result_t;

    typedef struct {
        bit            valid_context_switch;
        arr_psum_reg_t exp_pre_cswitch_arr_psum_reserve_reg;
    } systolic_array_context_switch_result_t;

    typedef struct {
        srama_addr_t               srama_addr;   
        srama_data_t               srama_data;
        a_arr_data_t               a_arr; 
        bit [sauria_pkg::Y-1:0]    arr_byte_valid;
    
    } ifmaps_feeder_data_t;

    typedef struct {
        bit                     addr_mismatch;
        srama_addr_t            exp_srama_addr;
        bit                     tile_done_counter_mismatch;
        sauria_axi4_lite_data_t c_idx;
        sauria_axi4_lite_data_t x_idx;
        sauria_axi4_lite_data_t y_idx;
    } ifmaps_feeder_srama_access_result_t;

    typedef struct {
        bit          valid_entry;
        srama_addr_t srama_addr;
        srama_data_t exp_srama_data;
        a_arr_data_t exp_a_arr_data;
    } ifmaps_feeder_arr_feed_result_t;

    typedef struct {
        sramb_addr_t               sramb_addr;   
        sramb_data_t               sramb_data;
        b_arr_data_t               b_arr; 
        bit [sauria_pkg::X-1:0]    arr_byte_valid;
    
    } weights_feeder_data_t;

    typedef struct {
        bit                     addr_mismatch;
        sramb_addr_t            exp_sramb_addr;
        bit                     tile_done_counter_mismatch;
        sauria_axi4_lite_data_t w_idx;
        sauria_axi4_lite_data_t k_idx;
    } weights_feeder_sramb_access_result_t;

    typedef struct {
        bit          valid_entry;
        sramb_addr_t sramb_addr;
        sramb_data_t exp_sramb_data;
        b_arr_data_t exp_b_arr_data;
    } weights_feeder_arr_feed_result_t;

    typedef struct {
        bit                addr_mismatch;
        sauria_axi4_addr_t exp_addr;
        bit                burst_mismatch;
        int                psums_tile_idx;
        bit                debug_map_valid;
        gemm_sauria_addr_map_t debug_map;
    } dma_req_addr_check_result_t;

    typedef struct{
        sauria_ifmaps_elem_data_t ifmaps_data[$];
    } ifmaps_feeder_row_data_t;

    typedef struct{
        sauria_weights_elem_data_t weights_data[$];
    } weights_feeder_col_data_t;



    

