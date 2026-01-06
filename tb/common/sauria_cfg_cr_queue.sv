class CFG_CR_queue  #(type T = sauria_axi4_lite_wr_txn_seq_item) extends uvm_queue #(T);

    `uvm_object_utils(CFG_CR_queue)

    function new(string name="CFG_CR_queue");
        super.new(name);
    endfunction

    virtual function void push_back(sauria_axi4_lite_wr_txn_seq_item item);
        super.push_back(item);
    endfunction
    
endclass
typedef CFG_CR_queue#(sauria_axi4_lite_wr_txn_seq_item) sauria_cfg_cr_queue;
