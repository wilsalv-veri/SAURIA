class sauria_axi4_lite_rd_data_seq_item extends sauria_axi4_lite_base_seq_item;

    sauria_axi4_lite_data_t  rdata;
    sauria_axi_resp_t        rresp;
    bit                      rvalid;
    bit                      rready;
    
    function new(string name="sauria_axi4_lite_rd_data_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_lite_rd_data_seq_item)
        `uvm_field_int(rdata,  UVM_ALL_ON)
        `uvm_field_int(rresp,  UVM_ALL_ON)
        `uvm_field_int(rvalid, UVM_ALL_ON)
        `uvm_field_int(rready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass