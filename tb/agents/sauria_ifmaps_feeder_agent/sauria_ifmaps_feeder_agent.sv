class sauria_ifmaps_feeder_agent extends uvm_agent;

    `uvm_component_utils(sauria_ifmaps_feeder_agent)

    string message_id = "SAURIA_IFMAPS_FEEDER_AGENT";
    sauria_ifmaps_feeder_monitor ifmaps_feeder_mon;

    function new(string name="sauria_ifmaps_feeder_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        ifmaps_feeder_mon = sauria_ifmaps_feeder_monitor::type_id::create("sauria_ifmaps_feeder_monitor", this);
    endfunction

endclass

