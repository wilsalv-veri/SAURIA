class sauria_computation_params extends uvm_object;

    bit shared;
    
    int ifmap_X;
    int ifmap_Y;
    int ifmap_C;

    int weights_W;
    int weights_K;

    `uvm_object_utils_begin(sauria_computation_params)
        `uvm_field_int(ifmap_X,   UVM_ALL_ON)
        `uvm_field_int(ifmap_Y,   UVM_ALL_ON)
        `uvm_field_int(ifmap_C,   UVM_ALL_ON)

        `uvm_field_int(weights_W, UVM_ALL_ON)
        `uvm_field_int(weights_K, UVM_ALL_ON)
    `uvm_object_utils_end    

    function new(string name="sauria_computation_params");
        super.new(name);
    endfunction

endclass