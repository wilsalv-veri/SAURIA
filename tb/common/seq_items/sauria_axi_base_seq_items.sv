class sauria_axi_base_seq_item extends uvm_sequence_item;

    sauria_axi_type_t    axi_type;
    sauria_axi_ch_type_t ch_type;

    function new(string name="sauria_axi_base_seq_item");
        super.new(name);
    endfunction

    `uvm_object_utils_begin(sauria_axi_base_seq_item)
        `uvm_field_enum(sauria_axi_type_t,    axi_type, UVM_ALL_ON)
        `uvm_field_enum(sauria_axi_ch_type_t, ch_type,  UVM_ALL_ON)
    `uvm_object_utils_end

endclass

class sauria_axi4_lite_base_seq_item extends sauria_axi_base_seq_item;

    `uvm_object_utils(sauria_axi4_lite_base_seq_item)

    function new(string name="sauria_axi4_lite_base_seq_item");
        super.new(name);
        axi_type = AXI4_LITE;
    endfunction

endclass

class sauria_axi4_base_seq_item extends sauria_axi_base_seq_item;

    `uvm_object_utils(sauria_axi4_base_seq_item)

    function new(string name="sauria_axi4_base_seq_item");
        super.new(name);
        axi_type = AXI4;
    endfunction
    
endclass