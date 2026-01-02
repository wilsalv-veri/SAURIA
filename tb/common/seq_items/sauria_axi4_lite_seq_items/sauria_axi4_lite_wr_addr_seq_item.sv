class sauria_axi4_lite_wr_addr_seq_item extends sauria_axi4_lite_base_seq_item;

    sauria_axi4_lite_addr_t  awaddr;
    sauria_axi_prot_t        awprot;
    bit                      awvalid;
    bit                      awready;
   
    function new(string name="sauria_axi4_lite_wr_addr_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_lite_wr_addr_seq_item)
        `uvm_field_int(awaddr,  UVM_ALL_ON)
        `uvm_field_int(awprot,  UVM_ALL_ON)
        `uvm_field_int(awvalid, UVM_ALL_ON)
        `uvm_field_int(awready, UVM_ALL_ON)
    `uvm_object_utils_end

endclass