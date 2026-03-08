class sauria_weights_feeder_agent extends uvm_agent;

    `uvm_component_utils(sauria_weights_feeder_agent)

    string mesage_id = "SAURIA_WEIGHTS_FEEDER_AGENT";

    sauria_weights_feeder_monitor weights_feeder_mon;

    function new(string name="sauria_weights_feeder_agent", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        weights_feeder_mon = sauria_weights_feeder_monitor::type_id::create("sauria_weights_feeder_monitor", this);
    endfunction

endclass