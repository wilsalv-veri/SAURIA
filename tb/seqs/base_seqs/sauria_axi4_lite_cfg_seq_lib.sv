class sauria_axi4_lite_cfg_seq_lib extends uvm_sequence_library #(sauria_axi_txn_base_seq_item);

    `uvm_object_utils(sauria_axi4_lite_cfg_seq_lib)
    `uvm_sequence_library_utils(sauria_axi4_lite_cfg_seq_lib)
    
    string message_id  = "SAURIA_AXI4_LITE_CFG_SEQ_LIB";
    int num_of_sequences;
    
    function new(string name="sauria_axi4_lite_cfg_seq_lib");
        super.new(name);
        sequence_count   = 0;
        num_of_sequences = 6;
        sequence_count   = num_of_sequences;
        add_sauria_cfg_seqs();
        init_sequence_library();
    endfunction
    
    virtual task body();
        super.body();
    endtask

    virtual function void add_sauria_cfg_seqs();
        add_dma_controller_cfg_sequence();
        add_df_controller_cfg_seq();
        add_core_main_controller_cfg_sequence();
        add_core_ifmaps_cfg_sequence();
        add_core_weights_cfg_sequence();
        add_core_psums_cfg_sequence();
    endfunction

    virtual function void add_df_controller_cfg_seq(); 
        add_typewide_sequence(sauria_axi4_lite_df_controller_cfg_base_seq::get_type());
    endfunction

    virtual function void add_dma_controller_cfg_sequence(); 
        add_typewide_sequence(sauria_axi4_lite_dma_controller_cfg_base_seq::get_type());
    endfunction

    virtual function void add_core_main_controller_cfg_sequence();
        add_typewide_sequence(sauria_axi4_lite_core_main_controller_cfg_base_seq::get_type());
    endfunction

    virtual function void add_core_ifmaps_cfg_sequence(); 
        add_typewide_sequence(sauria_axi4_lite_core_ifmaps_cfg_base_seq::get_type());
    endfunction

    virtual function void add_core_weights_cfg_sequence(); 
        add_typewide_sequence(sauria_axi4_lite_core_weights_cfg_base_seq::get_type());
    endfunction

    virtual function void add_core_psums_cfg_sequence(); 
        add_typewide_sequence(sauria_axi4_lite_core_psums_cfg_base_seq::get_type());
    endfunction

endclass