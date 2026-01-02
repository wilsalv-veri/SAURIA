class sauria_axi4_lite_base_seq extends uvm_sequence #(sauria_axi4_lite_base_seq_item);

    `uvm_object_utils(sauria_axi4_lite_base_seq)

    sauria_axi4_lite_base_seq_item axi4_lite_item;

    function new(string name="sauria_axi4_lite_base_seq");
        super.new(name);
    endfunction

    task body();
        axi4_lite_item = sauria_axi4_lite_base_seq_item::type_id::create("sauria_axi4_lite_base_seq_item");
        start_item(axi4_lite_item);
        
        //RANDOMIZE/MODIFY ITEM

        finish_item(axi4_lite_item);
    endtask
endclass
