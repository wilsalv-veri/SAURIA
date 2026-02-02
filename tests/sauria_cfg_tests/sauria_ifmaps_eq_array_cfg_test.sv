class sauria_ifmaps_eq_array_cfg_test extends sauria_base_test;

    `uvm_component_utils(sauria_ifmaps_eq_array_cfg_test)

    function new(string name="sauria_ifmaps_eq_array_cfg_test", uvm_component parent=null);
        super.new(name,parent);
        message_id = "SAURIA_IFMAPS_EQ_ARRAY_CFG_TEST";
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(sauria_axi4_lite_df_controller_cfg_base_seq::get_type(),  sauria_rand_df_controller_cfg_seq::get_type());
        set_type_override_by_type(sauria_axi4_lite_dma_controller_cfg_base_seq::get_type(), sauria_ifmaps_eq_array_dma_ctrl_cfg_seq::get_type());
        super.build_phase(phase);
    endfunction

endclass