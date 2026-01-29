import sauria_common_pkg::*;
import uvm_pkg::*;

class sauria_w_dma_base_test extends uvm_test;

    `uvm_component_utils(sauria_w_dma_base_test)

    string message_id = "SAURIA_W_DMA_BASE_TEST";
    sauria_env                env;
    sauria_axi4_base_vseq     vseq;
    
    virtual sauria_subsystem_ifc     sauria_ss_if;
    virtual sauria_df_controller_ifc sauria_df_ctrl_if;
   
    function new(string name="sauria_w_dma_base_test", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = sauria_env::type_id::create("sauria_env", this);
        vseq = sauria_axi4_base_vseq::type_id::create("sauria_axi4_base_vseq");
        
        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

        if (!uvm_config_db #(virtual sauria_df_controller_ifc)::get(this, "", "sauria_df_ctrl_if", sauria_df_ctrl_if))
            `sauria_error(message_id, "Failed to get access to sauria_df_ctrl_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        fork
            wait_for_seq_completion(phase);
            wait_for_fsm_done(phase);
        join
        
    endtask

    virtual task wait_for_seq_completion(uvm_phase phase);
        phase.raise_objection(this);
        vseq.start(env.vseqr);
        phase.drop_objection(this);
    endtask

    virtual task wait_for_fsm_done(uvm_phase phase);
        phase.raise_objection(this);
            wait (sauria_ss_if.o_intr);
            wait   (sauria_df_ctrl_if.dma_tile_ptr_advance);
            repeat (2) @ (posedge sauria_ss_if.i_sauria_clk);
        phase.drop_objection(this);
    endtask

endclass