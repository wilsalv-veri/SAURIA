class sauria_axi4_agent extends uvm_agent;

    `uvm_component_utils (sauria_axi4_agent)

    //sauria_axi4_driver  axi4_drv;
    // sauria_axi4_monitor axi4_mon;
    uvm_sequencer #(sauria_axi4_base_seq_item) axi4_seqr;

    function new(string name="sauria_axi4_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        //axi4_drv = sauria_axi4_driver::type_id::create("sauria_axi4_driver", this);
        //axi4_mon = sauria_axi4_monitor::type_id::create("sauria_axi4_monitor", this);
        axi4_seqr = uvm_sequencer #(sauria_axi4_base_seq_item)::type_id::create("AXI4_SEQR", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        //axi4_drv.seq_item_port.connect(axi4_seqr.seq_item_export);
    endfunction

endclass