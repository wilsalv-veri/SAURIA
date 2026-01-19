class sauria_axi4_wr_addr_seq_item extends sauria_axi4_base_seq_item;

    sauria_axi4_id_t        awid;
    sauria_axi4_addr_t      awaddr;
    sauria_axi_prot_t       awprot;
    sauria_axi_burst_t      awburst;
    sauria_axi_len_t        awlen;
    bit                     awvalid;
    sauria_axi_size_t       awsize;
    bit                     awlock;
    sauria_axi_cache_t      awcache;
    sauria_axi_qos_t        awqos;
    sauria_axi_region_t     awregion;
    bit              awready;
   
    function new(string name="sauria_axi4_wr_addr_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi4_wr_addr_seq_item)
        `uvm_field_int(awid, UVM_ALL_ON)
        `uvm_field_int(awaddr, UVM_ALL_ON)
        `uvm_field_int(awprot, UVM_ALL_ON)
        `uvm_field_int(awburst, UVM_ALL_ON)
        `uvm_field_int(awlen, UVM_ALL_ON)
        `uvm_field_int(awvalid, UVM_ALL_ON)
        `uvm_field_int(awsize, UVM_ALL_ON)
        `uvm_field_int(awlock, UVM_ALL_ON)
        `uvm_field_int(awcache, UVM_ALL_ON)
        `uvm_field_int(awqos, UVM_ALL_ON)
        `uvm_field_int(awregion, UVM_ALL_ON)
        `uvm_field_int(awready, UVM_ALL_ON)
    `uvm_object_utils_end
    
endclass