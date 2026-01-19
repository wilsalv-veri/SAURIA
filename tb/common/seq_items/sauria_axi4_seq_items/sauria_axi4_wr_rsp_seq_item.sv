class sauria_axi4_wr_rsp_seq_item extends sauria_axi4_base_seq_item;

    sauria_axi4_id_t      bid;
    sauria_axi_resp_t     bresp;
    bit                   bvalid;
    bit                   bready;
   
    function new(string name="sauria_axi4_wr_rsp_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_wr_rsp_seq_item)
        `uvm_field_int(bid,    UVM_ALL_ON)
        `uvm_field_int(bresp,  UVM_ALL_ON)
        `uvm_field_int(bvalid, UVM_ALL_ON)
        `uvm_field_int(bready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass