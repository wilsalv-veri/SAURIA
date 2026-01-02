class sauria_axi4_lite_driver extends uvm_driver #(sauria_axi4_lite_base_seq_item);

    `uvm_component_utils(sauria_axi4_lite_driver)

    string message_id  = "SAURIA_AXI4_LITE_DRIVER";

    sauria_axi4_lite_base_seq_item axi4_lite_base_item;
    virtual sauria_axi4_lite_ifc   sauria_axi4_lite_cfg_if;

    function new(string name="sauria_axi4_lite_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi4_lite_base_item = sauria_axi4_lite_base_seq_item::type_id::create("axi4_lite_base_seq_item");
        
        if (!uvm_config_db #(virtual sauria_axi4_lite_ifc)::get(this, "", "sauria_axi4_lite_cfg_if", sauria_axi4_lite_cfg_if))
            `uvm_error(message_id, "Failed to get access to axi4_lite_cfg_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        forever begin
            seq_item_port.get_next_item(axi4_lite_base_item);
            case(axi4_lite_base_item.ch_type)
                RD_ADDR: drive_rd_addr_ch(axi4_lite_base_item);
                RD_DATA: drive_rd_data_ch(axi4_lite_base_item);
                WR_ADDR: drive_wr_addr_ch(axi4_lite_base_item);
                WR_DATA: drive_wr_data_ch(axi4_lite_base_item);
                WR_RSP:  drive_wr_rsp_ch(axi4_lite_base_item);
            endcase
            seq_item_port.item_done();
        end
    endtask

    virtual task drive_rd_addr_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_rd_addr_seq_item rd_addr_item;
        
        if ($cast(rd_addr_item, axi4_lite_item))begin
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.araddr  <= rd_addr_item.araddr;  
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arprot  <= rd_addr_item.arprot;   
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arvalid <= rd_addr_item.arvalid;
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arready <= rd_addr_item.arready;
        end
        else `uvm_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_rd_addr_seq_item")
        
    endtask

    virtual task drive_rd_data_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_rd_data_seq_item rd_data_item;
        
        if ($cast(rd_data_item, axi4_lite_item))begin
            sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rdata  <=  rd_data_item.rdata;
            sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rresp  <=  rd_data_item.rresp;
            sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid <=  rd_data_item.rvalid;
            sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rready <=  rd_data_item.rready;
        end
        else `uvm_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_rd_data_seq_item")

    endtask

    virtual task drive_wr_addr_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_wr_addr_seq_item wr_addr_item;
        
        if ($cast(wr_addr_item, axi4_lite_item))begin
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awaddr  <=  wr_addr_item.awaddr;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awprot  <=  wr_addr_item.awprot;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awvalid <=  wr_addr_item.awvalid;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awready <=  wr_addr_item.awready;
   
        end
        else `uvm_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_addr_seq_item")

    endtask

    virtual task drive_wr_data_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_wr_data_seq_item wr_data_item;
        
        if ($cast(wr_data_item, axi4_lite_item)) begin
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wdata  <= wr_data_item.wdata;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wstrb  <= wr_data_item.wstrb;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wvalid <= wr_data_item.wvalid;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wready <= wr_data_item.wready;
        end
        else `uvm_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_data_seq_item")

    endtask

    virtual task drive_wr_rsp_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_wr_rsp_seq_item wr_rsp_item;
        
        if ($cast(wr_rsp_item, axi4_lite_item))begin
            sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bresp <= wr_rsp_item.bresp;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bvalid <= wr_rsp_item.bvalid;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bready <= wr_rsp_item.bready;
        end
        else `uvm_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_rsp_seq_item")

    endtask

endclass