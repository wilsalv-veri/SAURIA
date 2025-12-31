    assign i_sauria_clk       = sa_ss_ifc.i_sauria_clk;
    assign i_system_clk       = sa_ss_ifc.i_system_clk;
          
    assign i_sauria_rstn      = sa_ss_ifc.i_sauria_rstn;
    assign i_system_rstn      = sa_ss_ifc.i_system_rstn;

    assign i_cfg_axi_araddr   = sa_ss_ifc.i_cfg_axi_araddr;
    assign i_cfg_axi_arprot   = sa_ss_ifc.i_cfg_axi_arprot;  
    assign i_cfg_axi_arvalid  = sa_ss_ifc.i_cfg_axi_arvalid;
    assign o_cfg_axi_arready  = sa_ss_ifc.o_cfg_axi_arready;  

    assign o_cfg_axi_rdata    = sa_ss_ifc.o_cfg_axi_rdata;
    assign o_cfg_axi_rresp    = sa_ss_ifc.o_cfg_axi_rresp;
    assign o_cfg_axi_rvalid   = sa_ss_ifc.o_cfg_axi_rvalid;
    assign i_cfg_axi_rready   = sa_ss_ifc.i_cfg_axi_rready; 

    assign i_cfg_axi_awaddr   = sa_ss_ifc.i_cfg_axi_awaddr;  
    assign i_cfg_axi_awprot   = sa_ss_ifc.i_cfg_axi_awprot; 
    assign i_cfg_axi_awvalid  = sa_ss_ifc.i_cfg_axi_awvalid;  
    assign o_cfg_axi_awready  = sa_ss_ifc.o_cfg_axi_awready;  

    assign i_cfg_axi_wdata    = sa_ss_ifc.i_cfg_axi_wdata; 
    assign i_cfg_axi_wstrb    = sa_ss_ifc.i_cfg_axi_wstrb; 
    assign i_cfg_axi_wvalid   = sa_ss_ifc.i_cfg_axi_wvalid; 
    assign o_cfg_axi_wready   = sa_ss_ifc.o_cfg_axi_wready;  

    assign o_cfg_axi_bresp    = sa_ss_ifc.o_cfg_axi_bresp; 
    assign o_cfg_axi_bvalid   = sa_ss_ifc.o_cfg_axi_bvalid;  
    assign i_cfg_axi_bready   = sa_ss_ifc.i_cfg_axi_bready;  

    // Data AXI4 MASTER interface
    assign o_dat_axi_arid     = sa_ss_ifc.o_dat_axi_arid;  
    assign o_dat_axi_araddr   = sa_ss_ifc.o_dat_axi_araddr; 
    assign o_dat_axi_arprot   = sa_ss_ifc.o_dat_axi_arprot;  
    assign o_dat_axi_arburst  = sa_ss_ifc.o_dat_axi_arburst;   
    assign o_dat_axi_arlen    = sa_ss_ifc.o_dat_axi_arlen;  
    assign o_dat_axi_arvalid  = sa_ss_ifc.o_dat_axi_arvalid;   
    assign o_dat_axi_arsize   = sa_ss_ifc.o_dat_axi_arsize;  
    assign o_dat_axi_arlock   = sa_ss_ifc.o_dat_axi_arlock;   
    assign o_dat_axi_arcache  = sa_ss_ifc.o_dat_axi_arcache;    
    assign o_dat_axi_arqos    = sa_ss_ifc.o_dat_axi_arqos;  
    assign o_dat_axi_arregion = sa_ss_ifc.o_dat_axi_arregion;   
    
    assign i_dat_axi_arready  = sa_ss_ifc.i_dat_axi_arready;
    assign i_dat_axi_a        = sa_ss_ifc.i_dat_axi_a; 
    assign i_dat_axi_rid      = sa_ss_ifc.i_dat_axi_rid; 
    assign i_dat_axi_rdata    = sa_ss_ifc.i_dat_axi_rdata;   
    assign i_dat_axi_rresp    = sa_ss_ifc.i_dat_axi_rresp;   
    assign i_dat_axi_rvalid   = sa_ss_ifc.i_dat_axi_rvalid;   
    assign i_dat_axi_rlast    = sa_ss_ifc.i_dat_axi_rlast;    
    assign o_dat_axi_rready   = sa_ss_ifc.o_dat_axi_rready;     

    assign o_dat_axi_awid     = sa_ss_ifc.o_dat_axi_awid; 
    assign o_dat_axi_awaddr   = sa_ss_ifc.o_dat_axi_awaddr;  
    assign o_dat_axi_awprot   = sa_ss_ifc.o_dat_axi_awprot;   
    assign o_dat_axi_awburst  = sa_ss_ifc.o_dat_axi_awburst;   
    assign o_dat_axi_awlen    = sa_ss_ifc.o_dat_axi_awlen;   
    assign o_dat_axi_awvalid  = sa_ss_ifc.o_dat_axi_awvalid;   
    assign o_dat_axi_awsize   = sa_ss_ifc.o_dat_axi_awsize;  
    assign o_dat_axi_awlock   = sa_ss_ifc.o_dat_axi_awlock;   
    assign o_dat_axi_awcache  = sa_ss_ifc.o_dat_axi_awcache;    
    assign o_dat_axi_awqos    = sa_ss_ifc.o_dat_axi_awqos;   
    assign o_dat_axi_awregion = sa_ss_ifc.o_dat_axi_awregion;   
    assign i_dat_axi_awready  = sa_ss_ifc.i_dat_axi_awready; 

    assign o_dat_axi_wdata    = sa_ss_ifc.o_dat_axi_wdata;   
    assign o_dat_axi_wstrb    = sa_ss_ifc.o_dat_axi_wstrb;  
    assign o_dat_axi_wlast    = sa_ss_ifc.o_dat_axi_wlast;   
    assign o_dat_axi_wvalid   = sa_ss_ifc.o_dat_axi_wvalid;   
    assign i_dat_axi_wready   = sa_ss_ifc.i_dat_axi_wready;   

    assign i_dat_axi_bid      = sa_ss_ifc.i_dat_axi_bid; 
    assign i_dat_axi_bresp    = sa_ss_ifc.i_dat_axi_bresp;    
    assign i_dat_axi_bvalid   = sa_ss_ifc.i_dat_axi_bvalid;    
    assign o_dat_axi_bready   = sa_ss_ifc.o_dat_axi_bready;   

    // Control FSM Interrupt
    assign o_intr             = sa_ss_ifc.o_intr;

    // DMA Interrupt
    assign o_reader_dmaintr   = sa_ss_ifc.o_reader_dmaintr;    
    assign o_writer_dmaintr   = sa_ss_ifc.o_writer_dmaintr;   
    
    // SAURIA Interrupt
    assign o_sauriaintr       = sa_ss_ifc.o_sauriaintr;  
