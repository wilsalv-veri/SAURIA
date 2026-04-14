class sauria_perf_collector extends uvm_component;

    `uvm_component_utils(sauria_perf_collector)

    string message_id = "SAURIA_PERF_COLLECTOR";

    virtual sauria_core_ifc sauria_core_if;
    
    sauria_axi4_lite_seqr   axi4_lite_seqr;
   
    sauria_perf_scbd      perf_scbd;
    sauria_perf_seq       perf_seq;

    function new(string name="suria_perf_collector", uvm_component parent=null);
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        perf_seq  = sauria_perf_seq::type_id::create("sauria_perf_seq");
        perf_scbd = sauria_perf_scbd::type_id::create("sauria_perf_scbd", this);

        if (!uvm_config_db #(virtual sauria_core_ifc)::get(this, "", "sauria_core_if", sauria_core_if))
            `sauria_error(message_id, "Failed to get access to sauria_core_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        forever begin
            collect_perf();
        end
    
    endtask

    virtual task collect_perf();
        wait(sauria_core_if.o_doneintr)
        `sauria_info(message_id, "Core Computation Done. Interrupt Fired")
        perf_seq.start(axi4_lite_seqr);
    endtask

endclass
