class sauria_all_dim_multi_tile_cfg_test extends sauria_w_dma_base_test;

    `uvm_component_utils(sauria_all_dim_multi_tile_cfg_test)

    function new(string name="sauria_all_dim_multi_tile_cfg_test", uvm_component parent=null);
        super.new(name,parent);
        message_id = "SAURIA_ALL_DIM_MULTI_TILE_CFG_TEST";
    endfunction

    virtual function void build_phase(uvm_phase phase);
        set_type_override_by_type(sauria_axi4_lite_dma_controller_cfg_base_seq::get_type(), sauria_all_dim_multi_tile_dma_cfg_seq::get_type());
        super.build_phase(phase);
    endfunction

endclass
