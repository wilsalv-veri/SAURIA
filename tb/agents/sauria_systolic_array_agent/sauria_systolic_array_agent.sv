class sauria_systolic_array_agent extends uvm_agent;

    `uvm_component_utils(sauria_systolic_array_agent)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_AGENT";
    
    sauria_systolic_array_monitor systolic_array_mon;

    function new(string name="sauria_systolic_array_agent", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        systolic_array_mon = sauria_systolic_array_monitor::type_id::create("sauria_systolic_array_monitor", this);
    endfunction
endclass