class sauria_axi4_wr_txn_seq_item extends sauria_axi_txn_base_seq_item;

    `uvm_object_utils(sauria_axi4_wr_txn_seq_item)

    sauria_axi4_wr_addr_seq_item wr_addr_item;
    sauria_axi4_wr_data_seq_item wr_data_item;
    sauria_axi4_wr_rsp_seq_item  wr_rsp_item;

    function new(string name="sauria_axi4_wr_txn_seq_item");
        super.new(name);

        txn_type     = WR_TXN;
        wr_addr_item = sauria_axi4_wr_addr_seq_item::type_id::create("sauria_axi4_wr_addr_seq_item");
        wr_data_item = sauria_axi4_wr_data_seq_item::type_id::create("sauria_axi4_wr_data_seq_item");
        wr_rsp_item  = sauria_axi4_wr_rsp_seq_item::type_id::create("sauria_axi4_wr_rsp_seq_item");
    endfunction 

endclass