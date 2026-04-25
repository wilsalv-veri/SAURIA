class sauria_axi4_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_axi4_monitor)

    string message_id = "SAURIA_AXI4_MONITOR";
    
    virtual sauria_subsystem_ifc sauria_ss_if;
    virtual sauria_axi4_ifc      sauria_axi4_mem_if;
    
    uvm_analysis_port #(sauria_axi4_rd_addr_seq_item) send_dma_rd_addr;
    uvm_analysis_port #(sauria_axi4_wr_addr_seq_item) send_dma_wr_addr;

    uvm_analysis_port #(sauria_axi_txn_base_seq_item) send_dma_perf_info;

    sauria_axi4_wr_txn_seq_item  wr_txn_perf_item;
    sauria_axi4_rd_txn_seq_item  rd_txn_perf_item;

    sauria_axi4_rd_addr_seq_item rd_addr_item;
    sauria_axi4_rd_data_seq_item rd_data_item;

    sauria_axi4_wr_addr_seq_item wr_addr_item;
    sauria_axi4_wr_data_seq_item wr_data_item;

    function new(string name="sauria_axi4_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        send_dma_rd_addr   = new("SEND_DMA_RD_ADDR_ANALYSIS_PORT", this);
        send_dma_wr_addr   = new("SEND_DMA_WR_ADDR_ANALYSIS_PORT", this);
        send_dma_perf_info = new("SEND_DMA_PERF_INFO_ANALYSIS_PORT", this);
        
        rd_addr_item = sauria_axi4_rd_addr_seq_item::type_id::create("sauria_axi4_rd_addr_seq_item", this);
        rd_data_item = sauria_axi4_rd_data_seq_item::type_id::create("sauria_axi4_rd_data_seq_item", this);

        wr_addr_item = sauria_axi4_wr_addr_seq_item::type_id::create("sauria_axi4_wr_addr_seq_item", this);
        wr_data_item = sauria_axi4_wr_data_seq_item::type_id::create("sauria_axi4_wr_data_seq_item", this);

        wr_txn_perf_item = sauria_axi4_wr_txn_seq_item::type_id::create("sauria_axi4_wr_txn_seq_item");
        rd_txn_perf_item = sauria_axi4_rd_txn_seq_item::type_id::create("sauria_axi4_rd_txn_seq_item");

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")
    
        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(this, "", "sauria_axi4_mem_if", sauria_axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            collect_dma_rd_addr_req();
            collect_dma_wr_addr_req();
            collect_dma_perf_data();
        join
    endtask

    virtual task collect_dma_rd_addr_req();
        forever @ (posedge sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid)begin
            rd_addr_item.arid     =  sauria_axi4_mem_if.axi4_rd_addr_ch.arid;
            rd_addr_item.araddr   =  sauria_axi4_mem_if.axi4_rd_addr_ch.araddr;
            rd_addr_item.arprot   =  sauria_axi4_mem_if.axi4_rd_addr_ch.arprot;
            rd_addr_item.arburst  =  sauria_axi4_mem_if.axi4_rd_addr_ch.arburst;
            rd_addr_item.arlen    =  sauria_axi4_mem_if.axi4_rd_addr_ch.arlen;
            rd_addr_item.arvalid  =  sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid;
            rd_addr_item.arsize   =  sauria_axi4_mem_if.axi4_rd_addr_ch.arsize;
            rd_addr_item.arlock   =  sauria_axi4_mem_if.axi4_rd_addr_ch.arlock;
            rd_addr_item.arcache  =  sauria_axi4_mem_if.axi4_rd_addr_ch.arcache;
            rd_addr_item.arqos    =  sauria_axi4_mem_if.axi4_rd_addr_ch.arqos;
            rd_addr_item.arregion =  sauria_axi4_mem_if.axi4_rd_addr_ch.arregion;
            rd_addr_item.arready  =  sauria_axi4_mem_if.axi4_rd_addr_ch.arready ;
            send_dma_rd_addr.write(rd_addr_item);
        end
    endtask

    virtual task collect_dma_wr_addr_req();
        forever @ (posedge sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid)begin
            wr_addr_item.awid     =  sauria_axi4_mem_if.axi4_wr_addr_ch.awid;
            wr_addr_item.awaddr   =  sauria_axi4_mem_if.axi4_wr_addr_ch.awaddr;
            wr_addr_item.awprot   =  sauria_axi4_mem_if.axi4_wr_addr_ch.awprot;
            wr_addr_item.awburst  =  sauria_axi4_mem_if.axi4_wr_addr_ch.awburst;
            wr_addr_item.awlen    =  sauria_axi4_mem_if.axi4_wr_addr_ch.awlen;
            wr_addr_item.awvalid  =  sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid;
            wr_addr_item.awsize   =  sauria_axi4_mem_if.axi4_wr_addr_ch.awsize;
            wr_addr_item.awlock   =  sauria_axi4_mem_if.axi4_wr_addr_ch.awlock;
            wr_addr_item.awcache  =  sauria_axi4_mem_if.axi4_wr_addr_ch.awcache;
            wr_addr_item.awqos    =  sauria_axi4_mem_if.axi4_wr_addr_ch.awqos;
            wr_addr_item.awregion =  sauria_axi4_mem_if.axi4_wr_addr_ch.awregion;
            wr_addr_item.awready  =  sauria_axi4_mem_if.axi4_wr_addr_ch.awready ;
            send_dma_wr_addr.write(wr_addr_item);
        end
    endtask

    virtual task collect_dma_perf_data();
        forever @ (posedge sauria_ss_if.i_system_clk) begin
            
            if (sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid) begin
                rd_txn_perf_item.rd_addr_item.arid     = rd_addr_item.arid;
                rd_txn_perf_item.rd_addr_item.araddr   = rd_addr_item.araddr;
                rd_txn_perf_item.rd_addr_item.arburst  = rd_addr_item.arburst;
                rd_txn_perf_item.rd_addr_item.arlen    = rd_addr_item.arlen;
                rd_txn_perf_item.rd_addr_item.arsize   = rd_addr_item.arsize;
            end

            if (sauria_axi4_mem_if.axi4_rd_data_ch.rvalid) begin
                rd_txn_perf_item.rd_data_item.rdata  = sauria_axi4_mem_if.axi4_rd_data_ch.rdata;
                send_dma_perf_info.write(rd_txn_perf_item);
            end

            if (sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid) begin
                wr_txn_perf_item.wr_addr_item.awid     = wr_addr_item.awid;
                wr_txn_perf_item.wr_addr_item.awaddr   = wr_addr_item.awaddr;
                wr_txn_perf_item.wr_addr_item.awburst  = wr_addr_item.awburst;
                wr_txn_perf_item.wr_addr_item.awlen    = wr_addr_item.awlen;
                wr_txn_perf_item.wr_addr_item.awsize   = wr_addr_item.awsize;
            end

            if (sauria_axi4_mem_if.axi4_wr_data_ch.wvalid) begin
                wr_txn_perf_item.wr_data_item.wdata  = sauria_axi4_mem_if.axi4_wr_data_ch.wdata;
                send_dma_perf_info.write(wr_txn_perf_item);
            end
 
        end

    endtask

endclass