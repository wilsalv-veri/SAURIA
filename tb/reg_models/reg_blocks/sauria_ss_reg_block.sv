class sauria_ss_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_ss_reg_block)

    sauria_dma_controller_reg_block            dma_controller_reg_block;
    sauria_df_controller_reg_block             df_controller_reg_block;
    sauria_core_main_controller_reg_block      core_main_controller_reg_block;
    sauria_core_weights_reg_block              core_weights_reg_block;
    sauria_core_ifmaps_reg_block               core_ifmaps_reg_block;
    sauria_core_psums_reg_block                core_psums_reg_block;
    sauria_df_controller_ctrl_status_reg_block df_controller_ctrl_status_reg_block;
    sauria_core_ctrl_status_reg_block          core_ctrl_status_reg_block;

    function new(string name="sauria_ss_reg_block");
        super.new(name, UVM_NO_COVERAGE);
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");
        super.configure(parent, hdl_path);

        dma_controller_reg_block = sauria_dma_controller_reg_block::type_id::create("sauria_dma_controller_reg_block");
        dma_controller_reg_block.configure(this);

        df_controller_reg_block = sauria_df_controller_reg_block::type_id::create("sauria_df_controller_reg_block");
        df_controller_reg_block.configure(this);

        core_main_controller_reg_block = sauria_core_main_controller_reg_block::type_id::create("sauria_core_main_controller_reg_block");
        core_main_controller_reg_block.configure(this);

        core_weights_reg_block = sauria_core_weights_reg_block::type_id::create("sauria_core_weights_reg_block");
        core_weights_reg_block.configure(this);

        core_ifmaps_reg_block = sauria_core_ifmaps_reg_block::type_id::create("sauria_core_ifmaps_reg_block");
        core_ifmaps_reg_block.configure(this);

        core_psums_reg_block = sauria_core_psums_reg_block::type_id::create("sauria_core_psums_reg_block");
        core_psums_reg_block.configure(this);

        df_controller_ctrl_status_reg_block = sauria_df_controller_ctrl_status_reg_block::type_id::create("sauria_df_controller_ctrl_status_reg_block");
        df_controller_ctrl_status_reg_block.configure(this);

        core_ctrl_status_reg_block = sauria_core_ctrl_status_reg_block::type_id::create("sauria_core_ctrl_status_reg_block");
        core_ctrl_status_reg_block.configure(this);

    endfunction

endclass
