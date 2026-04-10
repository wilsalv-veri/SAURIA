class sauria_axi_vseqr extends uvm_sequencer;

    `uvm_component_utils(sauria_axi_vseqr)

    string message_id = "SAURIA_AXI_VSEQR";

    uvm_sequencer #(sauria_axi4_lite_wr_txn_seq_item) axi4_lite_seqr;
    uvm_sequencer #(sauria_tensor_mem_seq_item)       axi4_seqr;

    sauria_computation_params                         computation_params;

    function new(string name="sauria_axi_vseqr", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        computation_params = sauria_computation_params::type_id::create("sauria_computation_params");   
        uvm_config_db #(sauria_computation_params)::set(null, "*", "computation_params", computation_params);
    endfunction

endclass