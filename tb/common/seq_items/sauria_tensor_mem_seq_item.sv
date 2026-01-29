class sauria_tensor_mem_seq_item extends uvm_sequence_item;

    sauria_ifmaps_elem_data_t   ifmaps_elems[$];
    sauria_weights_elem_data_t  weights_elems[$];
    sauria_psums_elem_data_t    psums_elems[$];
    
    sauria_axi4_addr_t          row_addr;
    sauria_tensor_type_t        tensor_type;

    `uvm_object_utils_begin(sauria_tensor_mem_seq_item)
        `uvm_field_queue_int(ifmaps_elems, UVM_ALL_ON)
        `uvm_field_queue_int(weights_elems, UVM_ALL_ON)
        `uvm_field_queue_int(psums_elems, UVM_ALL_ON)
        
        `uvm_field_int(row_addr, UVM_ALL_ON)
        `uvm_field_enum(sauria_tensor_type_t, tensor_type, UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="sauria_tensor_mem_seq_item");
        super.new(name);
    endfunction
   
endclass