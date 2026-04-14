class sauria_perf_seq extends uvm_sequence;

    `uvm_object_utils(sauria_perf_seq)

    string message_id = "SAURIA_PERF_SEQ";

    sauria_core_ctrl_status_reg_block  core_ctrl_status_reg_block;
    uvm_status_e                       status;
    
    sauria_axi4_lite_data_t            perf_data;
    //sauria_axi4_lite_rd_txn_seq_item   perf_data;
        
    function new(string name="sauria_perf_seq");
        super.new(name);
    endfunction

    virtual task pre_start();
        sauria_axi4_lite_seqr axi4_lite_seqr;
    
        super.pre_start();
        
        if ($cast(axi4_lite_seqr, get_sequencer())) begin
            if (axi4_lite_seqr.subsystem_reg_block == null) begin
                `sauria_fatal(message_id, "Top-level regmodel handle on sequencer is null! Check env connection.")
            end
            this.core_ctrl_status_reg_block = axi4_lite_seqr.subsystem_reg_block.core_ctrl_status_reg_block;
        end
        else `sauria_error(message_id, "Sequencer handle is not of the expected type sauria_axi4_lite_seqr")
    endtask 

    task body();
        send_core_status_reads();
    endtask


    virtual task send_core_status_reads();
        core_ctrl_status_reg_block.core_ctrl_status_reg_5.read(status, perf_data);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while reading core_ctrl_status_reg_5")
        
        core_ctrl_status_reg_block.core_ctrl_status_reg_6.read(status, perf_data);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while reading core_ctrl_status_reg_6")

    endtask

endclass
