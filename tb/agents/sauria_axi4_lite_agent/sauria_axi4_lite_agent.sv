class sauria_axi4_lite_agent extends uvm_agent;

    `uvm_component_utils (sauria_axi4_lite_agent)

    sauria_axi4_lite_driver                             axi4_lite_drv;
    //sauria_axi4_lite_monitor                          axi4_lite_mon;
    uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item)   axi4_lite_seqr;

    function new(string name="sauria_axi4_lite_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi4_lite_drv  = sauria_axi4_lite_driver::type_id::create("sauria_axi4_lite_driver", this);
        //axi4_lite_mon  = sauria_axi4_lite_monitor::type_id::create("sauria_axi4_lite_monitor", this);
        axi4_lite_seqr = uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item)::type_id::create("sauria_axi4_lite_seqr", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        axi4_lite_drv.seq_item_port.connect(axi4_lite_seqr.seq_item_export);
    endfunction

endclass