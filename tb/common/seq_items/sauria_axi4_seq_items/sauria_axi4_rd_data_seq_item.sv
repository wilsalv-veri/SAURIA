class sauria_axi4_rd_data_seq_item extends sauria_axi4_base_seq_item;

    sauria_axi4_id_t      rid;
    sauria_axi4_data_t    rdata;
    sauria_axi_resp_t     rresp;
    bit                   rvalid;
    bit                   rlast;
    bit                   rready;
    
    function new(string name="sauria_axi4_rd_data_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_rd_data_seq_item)
        `uvm_field_int(rid,    UVM_ALL_ON)
        `uvm_field_int(rdata,  UVM_ALL_ON)
        `uvm_field_int(rresp,  UVM_ALL_ON)
        `uvm_field_int(rvalid, UVM_ALL_ON)
        `uvm_field_int(rlast,  UVM_ALL_ON)
        `uvm_field_int(rready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass