class sauria_axi4_lite_rd_addr_seq_item extends sauria_axi4_lite_base_seq_item;

    sauria_axi4_lite_addr_t  araddr;
    sauria_axi_prot_t        arprot;
    bit                      arvalid;
    bit                      arready;
   
    function new(string name="sauria_axi4_lite_rd_addr_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_lite_rd_addr_seq_item)
        `uvm_field_int(araddr,  UVM_ALL_ON)
        `uvm_field_int(arprot,  UVM_ALL_ON)
        `uvm_field_int(arvalid, UVM_ALL_ON)
        `uvm_field_int(arready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass