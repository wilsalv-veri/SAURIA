class sauria_axi4_lite_cfg_base_seq extends uvm_sequence #(sauria_axi4_lite_wr_txn_seq_item);
      
    `uvm_object_utils(sauria_axi4_lite_cfg_base_seq)

    string message_id = "SAURIA_AXI4_LITE_BASE_CFG_SEQ";
    parameter TIMEOUT_NS = 1000;
    sauria_computation_params    computation_params;

    sauria_axi4_lite_wr_txn_seq_item   axi4_lite_wr_txn_item;
    sauria_axi4_lite_wr_txn_seq_item   cfg_cr_queue[N_SEQ_REGS];
    int                                queue_running_idx;
    int                                queue_start_idx;
    int                                queue_end_idx;
    
    bit                                enable_done_interrupt = 1'b0;
    bit                                start_controller_fsm  = 1'b0;

    sauria_df_controller_reg_block     df_controller_reg_block;
    sauria_core_main_controller_reg_block core_main_controller_reg_block;
    sauria_core_weights_reg_block      core_weights_reg_block;
    sauria_core_ifmaps_reg_block       core_ifmaps_reg_block;
    sauria_core_psums_reg_block        core_psums_reg_block;

    function new(string name="sauria_axi4_lite_cfg_base_seq");
        super.new(name);
    endfunction
 
    virtual task pre_start();
        sauria_axi4_lite_seqr axi4_lite_seqr;
    
        super.pre_start();
        
        if ($cast(axi4_lite_seqr, get_sequencer())) begin

            if (!uvm_config_db #(sauria_computation_params)::get(axi4_lite_seqr, "","computation_params", computation_params))
                `sauria_error(message_id, "Failed to get access to computation params")

            if (axi4_lite_seqr.df_controller_reg_block == null) begin
                `sauria_fatal(message_id, "DF-controller regmodel handle on sequencer is null! Check env connection.")
            end
            this.df_controller_reg_block = axi4_lite_seqr.df_controller_reg_block;
        
            if (axi4_lite_seqr.core_main_controller_reg_block == null) begin
                `sauria_fatal(message_id, "Main-controller regmodel handle on sequencer is null! Check env connection.")
            end
            this.core_main_controller_reg_block = axi4_lite_seqr.core_main_controller_reg_block;

            if (axi4_lite_seqr.core_weights_reg_block == null) begin
                `sauria_fatal(message_id, "Weights regmodel handle on sequencer is null! Check env connection.")
            end
            this.core_weights_reg_block = axi4_lite_seqr.core_weights_reg_block;

            if (axi4_lite_seqr.core_ifmaps_reg_block == null) begin
                `sauria_fatal(message_id, "Ifmaps regmodel handle on sequencer is null! Check env connection.")
            end
            this.core_ifmaps_reg_block = axi4_lite_seqr.core_ifmaps_reg_block;

            if (axi4_lite_seqr.core_psums_reg_block == null) begin
                `sauria_fatal(message_id, "Psums regmodel handle on sequencer is null! Check env connection.")
            end
            this.core_psums_reg_block = axi4_lite_seqr.core_psums_reg_block;
        end
        else `sauria_error(message_id, "Sequencer handle is not of the expected type sauria_axi4_lite_seqr")

        if (!this.randomize())
            `sauria_error(message_id, "Failed to randomize sequence")
    
    endtask 

    virtual task body();
        configure_sauria();
        send_cfg_CRs();
    endtask

    virtual task configure_sauria();
        if (enable_done_interrupt) set_enable_done_interrupt();
        set_cfg_CRs();
    endtask

    virtual task send_cfg_CRs();
        `sauria_info(message_id, "Sending Config CRs")

        if (queue_start_idx == DF_CONTROLLER_CFG_CRs_START_IDX)
            send_df_controller_cfg_CRs();
        else if (queue_start_idx == CORE_MAIN_CONTROLLER_CFG_CRs_START_IDX)
            send_main_controller_cfg_CRs();
        else if (queue_start_idx == CORE_WEIGHTS_CFG_CRs_START_IDX)
            send_weights_cfg_CRs();
        else if (queue_start_idx == CORE_IFMAPS_CFG_CRs_START_IDX)
            send_ifmaps_cfg_CRs();
        else if (queue_start_idx == CORE_PSUMS_CFG_CRs_START_IDX)
            send_psums_cfg_CRs();
        else begin
            for(int idx = queue_start_idx; idx <= queue_end_idx; idx++)begin
                axi4_lite_wr_txn_item = cfg_cr_queue[idx];
                `sauria_info(message_id, $sformatf("Sending Config CR %0d With Value: 0x%0h", idx, axi4_lite_wr_txn_item.wr_data_item.wdata))

                start_item(axi4_lite_wr_txn_item);
                finish_item(axi4_lite_wr_txn_item);
            end
        end
        if (start_controller_fsm)  set_start_controller_fsm();    
    
    endtask

    virtual function void set_cfg_CRs();
        for(int cfg_cr_idx = queue_start_idx; cfg_cr_idx <= queue_end_idx; cfg_cr_idx++)begin
            
            create_wr_txn_with_name($sformatf("CFG_CR_IDX_%0d_wr_txn_item", cfg_cr_idx));
            `sauria_info(message_id, $sformatf("Adding Config CR %0d", cfg_cr_idx))

            set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('hf));
            set_cfg_cr_addr(get_cfg_addr_from_idx(cfg_cr_idx));

            add_unit_specific_cfg_CRs(cfg_cr_idx);
        end

    endfunction

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        //To be implemented by child class
    endfunction

    virtual task send_weights_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task send_df_controller_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task send_main_controller_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task send_ifmaps_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task send_psums_cfg_CRs();
        //To be implemented by child class
    endtask

    virtual task set_enable_done_interrupt();
        create_wr_txn_with_name("done_interrupt_en_wr_txn_item");
        `sauria_info(message_id, "Waiting for Grant ENABLE_DONE_INTERRUPT")
        start_item(axi4_lite_wr_txn_item);
        `sauria_info(message_id, "Sending ENABLE_DONE_INTERRUPT")
        set_cfg_cr_addr(sauria_axi4_lite_addr_t'('h8));
        set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('h1));
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h1));
        finish_item(axi4_lite_wr_txn_item);
    endtask

    virtual task set_start_controller_fsm();
        create_wr_txn_with_name("start_fsm_wr_txn_item");
        start_item(axi4_lite_wr_txn_item);
        `sauria_info(message_id, "Sending START_CONTROLLER_FSM")
        set_cfg_cr_addr(sauria_axi4_lite_addr_t'('h0));
        set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('h1));
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h1));
        finish_item(axi4_lite_wr_txn_item);
    endtask
    
    virtual function void create_wr_txn_with_name(string name);
        axi4_lite_wr_txn_item = sauria_axi4_lite_wr_txn_seq_item::type_id::create(name);
    endfunction

    virtual function void set_cfg_cr_strobe(sauria_axi4_lite_strobe_t wstrb);
        axi4_lite_wr_txn_item.wr_data_item.wstrb = wstrb; 
    endfunction

    virtual function void set_cfg_cr_addr(sauria_axi4_lite_addr_t awaddr);
        axi4_lite_wr_txn_item.wr_addr_item.awaddr = sauria_axi4_lite_addr_t'(CFG_BASE_OFFSET + awaddr); 
    endfunction

    virtual function void set_cfg_cr_data( sauria_axi4_lite_data_t wdata);
        axi4_lite_wr_txn_item.wr_data_item.wdata = wdata;
    endfunction

    virtual function  sauria_axi4_lite_data_t get_cfg_cr_data();
        return axi4_lite_wr_txn_item.wr_data_item.wdata;
    endfunction

    virtual task wait_comp_params_shared();
        fork 
            wait(computation_params.shared);
            begin #TIMEOUT_NS; `sauria_error(message_id, "Timeout waiting for shared flag"); end
        join_any
        disable fork;
    endtask

endclass
