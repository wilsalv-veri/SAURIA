class sauria_axi4_lite_adapter extends uvm_reg_adapter;

    `uvm_object_utils(sauria_axi4_lite_adapter)

    parameter ALL_BYTES_EN_STRB_VAL = 'hf;

    sauria_axi4_lite_wr_txn_seq_item axi4_lite_wr_txn_item;

    string message_id = "SAURIA_AXI4_LITE_ADAPTER";

    function new(string name="sauria_axi4_lite_adapter");
        super.new(name);
    endfunction

    virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
        axi4_lite_wr_txn_item = sauria_axi4_lite_wr_txn_seq_item::type_id::create("sauria_axi4_lite_wr_txn_seq_item");

        axi4_lite_wr_txn_item.txn_type = (rw.kind == UVM_READ) ? RD_TXN : WR_TXN;
        axi4_lite_wr_txn_item.wr_data_item.wstrb  = sauria_axi4_lite_strobe_t'(ALL_BYTES_EN_STRB_VAL);
        axi4_lite_wr_txn_item.wr_addr_item.awaddr = rw.addr;
        axi4_lite_wr_txn_item.wr_data_item.wdata  = rw.data;

        `sauria_info(message_id, $sformatf("AXI4_LITE Adapter ADDR: 0x%h DATA: 0x%0h", rw.addr, rw.data))

        return axi4_lite_wr_txn_item;
    endfunction

    function void bus2reg(uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);

    endfunction

    
endclass