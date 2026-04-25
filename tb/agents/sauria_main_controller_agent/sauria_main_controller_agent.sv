class sauria_main_controller_agent extends uvm_agent;

    `uvm_component_utils(sauria_main_controller_agent)

    sauria_main_controller_monitor main_controller_mon;

    function new(string name="sauria_main_controller_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        main_controller_mon = sauria_main_controller_monitor::type_id::create("sauria_main_controller_monitor", this);
    endfunction

endclass