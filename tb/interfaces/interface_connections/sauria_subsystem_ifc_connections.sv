assign i_sauria_clk       = sauria_subsystem_if.i_sauria_clk;
assign i_system_clk       = sauria_subsystem_if.i_system_clk;
          
assign i_sauria_rstn      = sauria_subsystem_if.i_sauria_rstn;
assign i_system_rstn      = sauria_subsystem_if.i_system_rstn;

//CFG AXI4-LITE SLAVE
assign i_cfg_axi_araddr   = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.araddr;
assign i_cfg_axi_arprot   = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arprot;  
assign i_cfg_axi_arvalid  = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arvalid;
assign o_cfg_axi_arready  = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arready;  

assign o_cfg_axi_rdata    = axi4_lite_cfg_if.axi4_lite_rd_data_ch.rdata;
assign o_cfg_axi_rresp    = axi4_lite_cfg_if.axi4_lite_rd_data_ch.rresp;
assign o_cfg_axi_rvalid   = axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid;
assign i_cfg_axi_rready   = axi4_lite_cfg_if.axi4_lite_rd_data_ch.rready; 

assign i_cfg_axi_awaddr   = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awaddr;  
assign i_cfg_axi_awprot   = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awprot; 
assign i_cfg_axi_awvalid  = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awvalid;  
assign o_cfg_axi_awready  = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awready;  

assign i_cfg_axi_wdata    = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wdata; 
assign i_cfg_axi_wstrb    = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wstrb; 
assign i_cfg_axi_wvalid   = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wvalid; 
assign o_cfg_axi_wready   = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wready;  

assign o_cfg_axi_bresp    = axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bresp; 
assign o_cfg_axi_bvalid   = axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bvalid;  
assign i_cfg_axi_bready   = axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bready;  

// Data AXI4 MASTER interface
assign o_dat_axi_arid     = axi4_mem_if.axi4_rd_addr_ch.arid;  
assign o_dat_axi_araddr   = axi4_mem_if.axi4_rd_addr_ch.araddr; 
assign o_dat_axi_arprot   = axi4_mem_if.axi4_rd_addr_ch.arprot;  
assign o_dat_axi_arburst  = axi4_mem_if.axi4_rd_addr_ch.arburst;   
assign o_dat_axi_arlen    = axi4_mem_if.axi4_rd_addr_ch.arlen;  
assign o_dat_axi_arvalid  = axi4_mem_if.axi4_rd_addr_ch.arvalid;   
assign o_dat_axi_arsize   = axi4_mem_if.axi4_rd_addr_ch.arsize;  
assign o_dat_axi_arlock   = axi4_mem_if.axi4_rd_addr_ch.arlock;   
assign o_dat_axi_arcache  = axi4_mem_if.axi4_rd_addr_ch.arcache;    
assign o_dat_axi_arqos    = axi4_mem_if.axi4_rd_addr_ch.arqos;  
assign o_dat_axi_arregion = axi4_mem_if.axi4_rd_addr_ch.arregion;   
assign i_dat_axi_arready  = axi4_mem_if.axi4_rd_addr_ch.arready;

assign i_dat_axi_rid      = axi4_mem_if.axi4_rd_data_ch.rid; 
assign i_dat_axi_rdata    = axi4_mem_if.axi4_rd_data_ch.rdata;   
assign i_dat_axi_rresp    = axi4_mem_if.axi4_rd_data_ch.rresp;   
assign i_dat_axi_rvalid   = axi4_mem_if.axi4_rd_data_ch.rvalid;   
assign i_dat_axi_rlast    = axi4_mem_if.axi4_rd_data_ch.rlast;    
assign o_dat_axi_rready   = axi4_mem_if.axi4_rd_data_ch.rready;     

assign o_dat_axi_awid     = axi4_mem_if.axi4_wr_addr_ch.awid; 
assign o_dat_axi_awaddr   = axi4_mem_if.axi4_wr_addr_ch.awaddr;  
assign o_dat_axi_awprot   = axi4_mem_if.axi4_wr_addr_ch.awprot;   
assign o_dat_axi_awburst  = axi4_mem_if.axi4_wr_addr_ch.awburst;   
assign o_dat_axi_awlen    = axi4_mem_if.axi4_wr_addr_ch.awlen;   
assign o_dat_axi_awvalid  = axi4_mem_if.axi4_wr_addr_ch.awvalid;   
assign o_dat_axi_awsize   = axi4_mem_if.axi4_wr_addr_ch.awsize;  
assign o_dat_axi_awlock   = axi4_mem_if.axi4_wr_addr_ch.awlock;   
assign o_dat_axi_awcache  = axi4_mem_if.axi4_wr_addr_ch.awcache;    
assign o_dat_axi_awqos    = axi4_mem_if.axi4_wr_addr_ch.awqos;   
assign o_dat_axi_awregion = axi4_mem_if.axi4_wr_addr_ch.awregion;   
assign i_dat_axi_awready  = axi4_mem_if.axi4_wr_addr_ch.awready; 

assign o_dat_axi_wdata    = axi4_mem_if.axi4_wr_data_ch.wdata;   
assign o_dat_axi_wstrb    = axi4_mem_if.axi4_wr_data_ch.wstrb;  
assign o_dat_axi_wlast    = axi4_mem_if.axi4_wr_data_ch.wlast;   
assign o_dat_axi_wvalid   = axi4_mem_if.axi4_wr_data_ch.wvalid;   
assign i_dat_axi_wready   = axi4_mem_if.axi4_wr_data_ch.wready;   

assign i_dat_axi_bid      = axi4_mem_if.axi4_wr_rsp_ch.bid; 
assign i_dat_axi_bresp    = axi4_mem_if.axi4_wr_rsp_ch.bresp;    
assign i_dat_axi_bvalid   = axi4_mem_if.axi4_wr_rsp_ch.bvalid;    
assign o_dat_axi_bready   = axi4_mem_if.axi4_wr_rsp_ch.bready;   

// Control FSM Interrupt
assign o_intr             = sauria_subsystem_if.o_intr;

// DMA Interrupt
assign o_reader_dmaintr   = sauria_subsystem_if.o_reader_dmaintr;    
assign o_writer_dmaintr   = sauria_subsystem_if.o_writer_dmaintr;   
    
// SAURIA Interrupt
assign o_sauriaintr       = sauria_subsystem_if.o_sauriaintr;  
