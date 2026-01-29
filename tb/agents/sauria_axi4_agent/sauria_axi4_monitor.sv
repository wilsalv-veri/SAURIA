class sauria_axi4_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_axi4_monitor)

    string message_id = "SAURIA_AXI4_MONITOR";
    
    virtual sauria_subsystem_ifc sauria_ss_if;
    virtual sauria_axi4_ifc      sauria_axi4_mem_if;
    
    uvm_analysis_port #(sauria_axi4_rd_addr_seq_item) send_dma_rd_addr;

    sauria_axi4_rd_addr_seq_item rd_addr_item;
    sauria_axi4_rd_data_seq_item rd_data_item;

    function new(string name="sauria_axi4_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        send_dma_rd_addr = new("SEND_DMA_RD_ADDR", this);
        
        rd_addr_item = sauria_axi4_rd_addr_seq_item::type_id::create("sauria_axi4_rd_addr_seq_item", this);
        rd_data_item = sauria_axi4_rd_data_seq_item::type_id::create("sauria_axi4_rd_data_seq_item", this);

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")
    
        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(this, "", "sauria_axi4_mem_if", sauria_axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            collect_dma_rd_addr_req();
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

endclass