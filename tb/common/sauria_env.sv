class sauria_env extends uvm_env;

    `uvm_component_utils(sauria_env)

    sauria_axi4_lite_agent axi4_lite_agent;
    sauria_axi4_agent      axi4_agent;

    sauria_axi_vseqr       vseqr;

    function new(string name="sauria_env", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        vseqr           = sauria_axi_vseqr::type_id::create("sauria_axi_vseqr", this);
        axi4_lite_agent = sauria_axi4_lite_agent::type_id::create("sauria_axi4_lite_agent", this);
        axi4_agent      = sauria_axi4_agent::type_id::create("sauria_axi4_agent", this);
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        vseqr.axi4_lite_seqr = axi4_lite_agent.axi4_lite_seqr;
        vseqr.axi4_seqr      = axi4_agent.axi4_seqr;
    endfunction

endclass