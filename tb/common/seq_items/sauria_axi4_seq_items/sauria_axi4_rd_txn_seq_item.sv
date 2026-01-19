class sauria_axi4_rd_txn_seq_item extends sauria_axi_txn_base_seq_item;

    `uvm_object_utils(sauria_axi4_rd_txn_seq_item)

    sauria_axi4_rd_addr_seq_item rd_addr_item;
    sauria_axi4_rd_data_seq_item rd_data_item;

    function new(string name="sauria_axi4_rd_txn_seq_item");
        super.new(name);

        rd_addr_item = sauria_axi4_rd_addr_seq_item::type_id::create("sauria_axi4_rd_addr_seq_item");
        rd_data_item = sauria_axi4_rd_data_seq_item::type_id::create("sauria_axi4_rd_data_seq_item");
    endfunction

endclass