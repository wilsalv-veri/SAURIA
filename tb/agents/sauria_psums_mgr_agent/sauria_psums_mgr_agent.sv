class sauria_psums_mgr_agent extends uvm_agent;

    `uvm_component_utils(sauria_psums_mgr_agent)

    sauria_psums_mgr_monitor psums_mgr_mon;

    function new(string name="", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        psums_mgr_mon = sauria_psums_mgr_monitor::type_id::create("sauria_psums_mgr_monitor", this);
    endfunction

endclass