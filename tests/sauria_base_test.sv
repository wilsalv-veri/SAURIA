import sauria_common_pkg::*;
import uvm_pkg::*;

class sauria_base_test extends uvm_test;

    `uvm_component_utils(sauria_base_test)

    sauria_env                env;
    sauria_axi4_lite_base_seq seq;

    function new(string name="sauria_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = sauria_env::type_id::create("sauria_env", this);
        seq = sauria_axi4_lite_base_seq::type_id::create("sauria_axi4_lite_base_seq");
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        phase.raise_objection(this);
            seq.start(env.axi4_lite_agent.axi4_lite_seqr);
        phase.drop_objection(this);
    endtask

endclass