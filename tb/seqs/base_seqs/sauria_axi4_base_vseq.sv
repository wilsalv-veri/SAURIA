class sauria_axi4_base_vseq extends uvm_sequence;

    `uvm_object_utils(sauria_axi4_base_vseq)

    string message_id = "SAURIA_AXI4_BASE_VSEQ";

    sauria_axi_vseqr                    vseqr;

    sauria_axi4_lite_cfg_seq_lib        axi4_lite_cfg_seq_lib;
    sauria_axi4_mem_base_seq            axi4_mem_seq;

    function new(string name="sauria_axi4_base_vseq");
        super.new(name);  
        axi4_lite_cfg_seq_lib = sauria_axi4_lite_cfg_seq_lib::type_id::create("sauria_axi4_lite_base_seq");
        axi4_mem_seq          = sauria_axi4_mem_base_seq::type_id::create("sauria_axi4_mem_base_seq");      
        init_cfg_seq_lib_parameters();
    endfunction

    task body();

        if(!$cast(vseqr, m_sequencer))
            `sauria_error(message_id, "Failed to cast m_sequencer into sauria_axi_vseqr")
        else
            `sauria_info(message_id, "Casted m_sequencer successfully")
    
        fork
            axi4_lite_cfg_seq_lib.start(vseqr.axi4_lite_seqr);
            axi4_mem_seq.start(vseqr.axi4_seqr);
        join

    endtask

    virtual function void init_cfg_seq_lib_parameters();
        axi4_lite_cfg_seq_lib.selection_mode = UVM_SEQ_LIB_USER;
        axi4_lite_cfg_seq_lib.min_random_count = 1;
        axi4_lite_cfg_seq_lib.max_random_count = 1000;
        `sauria_info(message_id, "Initialized Sequence Library")
    endfunction
    
endclass
