class sauria_axi4_lite_seqr extends uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item);

    `uvm_component_utils(sauria_axi4_lite_seqr)

    string message_id = "SAURIA_AXI4_LITE_SEQR";

    sauria_computation_params  computation_params;
    sauria_ss_reg_block        subsystem_reg_block;

    function new(string name="sauria_axi4_lite_seqr", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        computation_params = sauria_computation_params::type_id::create("sauria_computation_params");   
        uvm_config_db #(sauria_computation_params)::set(null, "*", "computation_params", computation_params);
    endfunction

endclass