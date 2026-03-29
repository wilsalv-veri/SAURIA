class sauria_axi4_lite_cfg_base_seq extends uvm_sequence #(sauria_axi4_lite_wr_txn_seq_item);
      
    `uvm_object_utils(sauria_axi4_lite_cfg_base_seq)

    string message_id = "SAURIA_AXI4_LITE_BASE_CFG_SEQ";
    parameter TIMEOUT_NS = 1000;
    sauria_computation_params    computation_params;

    sauria_ss_reg_block         subsystem_reg_block;

    function new(string name="sauria_axi4_lite_cfg_base_seq");
        super.new(name);
    endfunction
 
    virtual task pre_start();
        sauria_axi4_lite_seqr axi4_lite_seqr;
    
        super.pre_start();
        
        if ($cast(axi4_lite_seqr, get_sequencer())) begin

            if (!uvm_config_db #(sauria_computation_params)::get(axi4_lite_seqr, "","computation_params", computation_params))
                `sauria_error(message_id, "Failed to get access to computation params")

            if (axi4_lite_seqr.subsystem_reg_block == null) begin
                `sauria_fatal(message_id, "Top-level regmodel handle on sequencer is null! Check env connection.")
            end
            this.subsystem_reg_block = axi4_lite_seqr.subsystem_reg_block;
        end
        else `sauria_error(message_id, "Sequencer handle is not of the expected type sauria_axi4_lite_seqr")

        //1) Get Tile Dimensions(X, Y, W, C, K) and Tensor Dimensions 
        //2) Set IFMAPS and WEIGHTS
        //3) Set PSUMS
        repeat(3) begin
            if (!this.randomize())
                `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_cfg_w_dma_base_seq")
        end
    endtask 

    virtual task body();
        configure_sauria();
    endtask

    virtual task configure_sauria();
        set_unit_specific_cfg_CRs();
        send_unit_specific_cfg_CRs();
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        //To be implemented by child class
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task wait_comp_params_shared();
        fork 
            wait(computation_params.shared);
            begin #TIMEOUT_NS; `sauria_error(message_id, "Timeout waiting for shared flag"); end
        join_any
        disable fork;
    endtask

endclass
