class sauria_axi4_lite_wr_data_seq_item extends sauria_axi4_lite_base_seq_item;

    sauria_axi4_lite_data_t   wdata;
    sauria_axi4_lite_strobe_t wstrb;
    bit                       wvalid;
    bit                       wready;
   
    function new(string name="sauria_axi4_lite_wr_data_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_lite_wr_data_seq_item)
        `uvm_field_int(wdata,  UVM_ALL_ON)
        `uvm_field_int(wstrb,  UVM_ALL_ON)
        `uvm_field_int(wvalid, UVM_ALL_ON)
        `uvm_field_int(wready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass