class sauria_axi4_lite_adapter extends uvm_reg_adapter;

    `uvm_object_utils(sauria_axi4_lite_adapter)

    parameter ALL_BYTES_EN_STRB_VAL = 'hf;

    sauria_axi4_lite_wr_txn_seq_item axi4_lite_wr_txn_item;
    sauria_axi4_lite_rd_txn_seq_item axi4_lite_rd_txn_item;
    
    string message_id = "SAURIA_AXI4_LITE_ADAPTER";

    function new(string name="sauria_axi4_lite_adapter");
        super.new(name);
    endfunction

    virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
        if (rw.kind == UVM_READ)begin
            axi4_lite_rd_txn_item = sauria_axi4_lite_rd_txn_seq_item::type_id::create("sauria_axi4_lite_rd_txn_seq_item");

            axi4_lite_rd_txn_item.txn_type =  RD_TXN;
            axi4_lite_rd_txn_item.rd_addr_item.araddr = rw.addr[CFG_AXI_ADDR_WIDTH-1:0];
            axi4_lite_rd_txn_item.rd_data_item.rdata  = rw.data[CFG_AXI_DATA_WIDTH-1:0];

            `sauria_info(message_id, $sformatf("AXI4_LITE Adapter ADDR: 0x%h DATA: 0x%0h", rw.addr, rw.data))

            return axi4_lite_rd_txn_item;
        end
        else begin
            axi4_lite_wr_txn_item = sauria_axi4_lite_wr_txn_seq_item::type_id::create("sauria_axi4_lite_wr_txn_seq_item");

            axi4_lite_wr_txn_item.txn_type = WR_TXN;
            axi4_lite_wr_txn_item.wr_data_item.wstrb  = sauria_axi4_lite_strobe_t'(ALL_BYTES_EN_STRB_VAL);
            axi4_lite_wr_txn_item.wr_addr_item.awaddr = rw.addr[CFG_AXI_ADDR_WIDTH-1:0];
            axi4_lite_wr_txn_item.wr_data_item.wdata  = rw.data[CFG_AXI_DATA_WIDTH-1:0];

            `sauria_info(message_id, $sformatf("AXI4_LITE Adapter ADDR: 0x%h DATA: 0x%0h", rw.addr, rw.data))

            return axi4_lite_wr_txn_item;
        end
        
    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
        sauria_axi4_lite_rd_txn_seq_item axi4_lite_rd_txn_item;
        sauria_axi4_lite_wr_txn_seq_item axi4_lite_wr_txn_item;
        uvm_reg_addr_t reg_addr;
        uvm_reg_data_t reg_data;

        if ($cast(axi4_lite_rd_txn_item, bus_item)) begin
            rw.kind = UVM_READ;
            reg_addr = '0;
            reg_data = '0;
            reg_addr[CFG_AXI_ADDR_WIDTH-1:0] = axi4_lite_rd_txn_item.rd_addr_item.araddr;
            reg_data[CFG_AXI_DATA_WIDTH-1:0] = axi4_lite_rd_txn_item.rd_data_item.rdata;
            rw.addr = reg_addr;
            rw.data = reg_data;

            if ((axi4_lite_rd_txn_item.rd_data_item.rresp == 2'h0) ||
                (axi4_lite_rd_txn_item.rd_data_item.rresp == 2'h1))
                rw.status = UVM_IS_OK;
            else
                rw.status = UVM_NOT_OK;
        end
        else if ($cast(axi4_lite_wr_txn_item, bus_item)) begin
            rw.kind = UVM_WRITE;
            reg_addr = '0;
            reg_data = '0;
            reg_addr[CFG_AXI_ADDR_WIDTH-1:0] = axi4_lite_wr_txn_item.wr_addr_item.awaddr;
            reg_data[CFG_AXI_DATA_WIDTH-1:0] = axi4_lite_wr_txn_item.wr_data_item.wdata;
            rw.addr = reg_addr;
            rw.data = reg_data;

            if ((axi4_lite_wr_txn_item.wr_rsp_item.bresp == 2'h0) ||
                (axi4_lite_wr_txn_item.wr_rsp_item.bresp == 2'h1))
                rw.status = UVM_IS_OK;
            else
                rw.status = UVM_NOT_OK;
        end
        else begin
            `sauria_error(message_id, "Failed to cast bus_item into axi4_lite_{rd,wr}_txn_seq_item")
            rw.status = UVM_NOT_OK;
        end

    endfunction

    
endclass