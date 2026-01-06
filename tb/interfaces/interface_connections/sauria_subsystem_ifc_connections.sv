assign i_sauria_clk                                  = sauria_subsystem_if.i_sauria_clk;
assign i_system_clk                                  = sauria_subsystem_if.i_system_clk;
          
assign i_sauria_rstn                                 = sauria_subsystem_if.i_sauria_rstn;
assign i_system_rstn                                 = sauria_subsystem_if.i_system_rstn;

//CFG AXI4-LITE SLAVE
assign i_cfg_axi_araddr                              = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.araddr;
assign i_cfg_axi_arprot                              = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arprot;  
assign i_cfg_axi_arvalid                             = axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arvalid;
assign axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arready = o_cfg_axi_arready;  

assign axi4_lite_cfg_if.axi4_lite_rd_data_ch.rdata   = o_cfg_axi_rdata;  
assign axi4_lite_cfg_if.axi4_lite_rd_data_ch.rresp   = o_cfg_axi_rresp;       
assign axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid  = o_cfg_axi_rvalid;      
assign i_cfg_axi_rready                              = axi4_lite_cfg_if.axi4_lite_rd_data_ch.rready; 

assign i_cfg_axi_awaddr                              = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awaddr;  
assign i_cfg_axi_awprot                              = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awprot; 
assign i_cfg_axi_awvalid                             = axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awvalid;  
assign axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awready = o_cfg_axi_awready;  

assign i_cfg_axi_wdata                               = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wdata; 
assign i_cfg_axi_wstrb                               = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wstrb; 
assign i_cfg_axi_wvalid                              = axi4_lite_cfg_if.axi4_lite_wr_data_ch.wvalid; 
assign axi4_lite_cfg_if.axi4_lite_wr_data_ch.wready  = o_cfg_axi_wready;  

assign axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bresp    = o_cfg_axi_bresp;   
assign axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bvalid   = o_cfg_axi_bvalid;    
assign i_cfg_axi_bready                              = axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bready;  

// Data AXI4 MASTER interface
assign axi4_mem_if.axi4_rd_addr_ch.arid              = o_dat_axi_arid;   
assign axi4_mem_if.axi4_rd_addr_ch.araddr            = o_dat_axi_araddr; 
assign axi4_mem_if.axi4_rd_addr_ch.arprot            = o_dat_axi_arprot;  
assign axi4_mem_if.axi4_rd_addr_ch.arburst           = o_dat_axi_arburst;   
assign axi4_mem_if.axi4_rd_addr_ch.arlen             = o_dat_axi_arlen;  
assign axi4_mem_if.axi4_rd_addr_ch.arvalid           = o_dat_axi_arvalid;   
assign axi4_mem_if.axi4_rd_addr_ch.arsize            = o_dat_axi_arsize;  
assign axi4_mem_if.axi4_rd_addr_ch.arlock            = o_dat_axi_arlock;   
assign axi4_mem_if.axi4_rd_addr_ch.arcache           = o_dat_axi_arcache;    
assign axi4_mem_if.axi4_rd_addr_ch.arqos             = o_dat_axi_arqos;  
assign axi4_mem_if.axi4_rd_addr_ch.arregion          = o_dat_axi_arregion;   
assign i_dat_axi_arready                             = axi4_mem_if.axi4_rd_addr_ch.arready  ;

assign i_dat_axi_rid                                 = axi4_mem_if.axi4_rd_data_ch.rid; 
assign i_dat_axi_rdata                               = axi4_mem_if.axi4_rd_data_ch.rdata;   
assign i_dat_axi_rresp                               = axi4_mem_if.axi4_rd_data_ch.rresp;   
assign i_dat_axi_rvalid                              = axi4_mem_if.axi4_rd_data_ch.rvalid;   
assign i_dat_axi_rlast                               = axi4_mem_if.axi4_rd_data_ch.rlast;    
assign axi4_mem_if.axi4_rd_data_ch.rready            = o_dat_axi_rready;     

assign axi4_mem_if.axi4_wr_addr_ch.awid              =  o_dat_axi_awid; 
assign axi4_mem_if.axi4_wr_addr_ch.awaddr            =  o_dat_axi_awaddr;  
assign axi4_mem_if.axi4_wr_addr_ch.awprot            =  o_dat_axi_awprot;   
assign axi4_mem_if.axi4_wr_addr_ch.awburst           =  o_dat_axi_awburst;   
assign axi4_mem_if.axi4_wr_addr_ch.awlen             =  o_dat_axi_awlen;   
assign axi4_mem_if.axi4_wr_addr_ch.awvalid           =  o_dat_axi_awvalid;   
assign axi4_mem_if.axi4_wr_addr_ch.awsize            =  o_dat_axi_awsize;  
assign axi4_mem_if.axi4_wr_addr_ch.awlock            =  o_dat_axi_awlock;   
assign axi4_mem_if.axi4_wr_addr_ch.awcache           =  o_dat_axi_awcache;    
assign axi4_mem_if.axi4_wr_addr_ch.awqos             =  o_dat_axi_awqos;   
assign axi4_mem_if.axi4_wr_addr_ch.awregion          =  o_dat_axi_awregion;   
assign i_dat_axi_awready                             =  axi4_mem_if.axi4_wr_addr_ch.awready; 

assign axi4_mem_if.axi4_wr_data_ch.wdata             =  o_dat_axi_wdata;  
assign axi4_mem_if.axi4_wr_data_ch.wstrb             =  o_dat_axi_wstrb; 
assign axi4_mem_if.axi4_wr_data_ch.wlast             =  o_dat_axi_wlast;  
assign axi4_mem_if.axi4_wr_data_ch.wvalid            =  o_dat_axi_wvalid;   
assign i_dat_axi_wready                              =  axi4_mem_if.axi4_wr_data_ch.wready;   

assign i_dat_axi_bid                                 = axi4_mem_if.axi4_wr_rsp_ch.bid; 
assign i_dat_axi_bresp                               = axi4_mem_if.axi4_wr_rsp_ch.bresp;    
assign i_dat_axi_bvalid                              = axi4_mem_if.axi4_wr_rsp_ch.bvalid;    
assign axi4_mem_if.axi4_wr_rsp_ch.bready             = o_dat_axi_bready;   

// Control FSM Interrupt
assign  sauria_subsystem_if.o_intr                   = o_intr;

// DMA Interrupt
assign sauria_subsystem_if.o_reader_dmaintr          = o_reader_dmaintr;    
assign sauria_subsystem_if.o_writer_dmaintr          = o_writer_dmaintr;   
    
// SAURIA Interrupt
assign sauria_subsystem_if.o_sauriaintr              = o_sauriaintr;  
