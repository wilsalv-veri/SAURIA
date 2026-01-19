class sauria_axi4_rd_addr_seq_item extends sauria_axi4_base_seq_item;

    sauria_axi4_id_t        arid;
    sauria_axi4_addr_t      araddr;
    sauria_axi_prot_t       arprot;
    sauria_axi_burst_t      arburst;
    sauria_axi_len_t        arlen;
    bit                     arvalid;
    sauria_axi_size_t       arsize;
    bit                     arlock;
    sauria_axi_cache_t      arcache;
    sauria_axi_qos_t        arqos;
    sauria_axi_region_t     arregion;
    bit                     arready;
 
    function new(string name="sauria_axi4_rd_addr_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_rd_addr_seq_item)
        `uvm_field_int(arid,     UVM_ALL_ON)
        `uvm_field_int(araddr,   UVM_ALL_ON)
        `uvm_field_int(arprot,   UVM_ALL_ON)
        `uvm_field_int(arburst,  UVM_ALL_ON)
        `uvm_field_int(arlen,    UVM_ALL_ON)
        `uvm_field_int(arvalid,  UVM_ALL_ON)
        `uvm_field_int(arsize,   UVM_ALL_ON)
        `uvm_field_int(arlock,   UVM_ALL_ON)
        `uvm_field_int(arcache,  UVM_ALL_ON)
        `uvm_field_int(arqos,    UVM_ALL_ON)
        `uvm_field_int(arregion, UVM_ALL_ON)
        `uvm_field_int(arready,  UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass