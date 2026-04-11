class sauria_axi4_lite_ctrl_status_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_ctrl_status_cfg_base_seq)

    uvm_status_e                  status;
    sauria_df_controller_ctrl_status_reg_block  ctrl_status_reg_block;

    function new(string name="sauria_axi4_lite_ctrl_status_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CTRL_STATUS_CFG_BASE_SEQ";
    endfunction

    virtual task pre_start();
        super.pre_start();
        this.ctrl_status_reg_block = subsystem_reg_block.df_controller_ctrl_status_reg_block;
    endtask

    virtual function void set_unit_specific_cfg_CRs();
        set_ctrl_status_reg_2();
        set_ctrl_status_reg_0();
    endfunction

    virtual task send_unit_specific_cfg_CRs();
        ctrl_status_reg_block.ctrl_status_reg_2.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while writing ctrl_status_reg_2");

        ctrl_status_reg_block.ctrl_status_reg_0.update(status);
        if (status != UVM_IS_OK)
            `sauria_error(message_id, "Status not OK while writing ctrl_status_reg_0");
    endtask

    virtual function void set_ctrl_status_reg_0();
        ctrl_status_reg_block.ctrl_status_reg_0.start.set(uvm_reg_data_t'('h1));
    endfunction

    virtual function void set_ctrl_status_reg_2();
        ctrl_status_reg_block.ctrl_status_reg_2.done_interrupt_en.set(uvm_reg_data_t'('h1));
    endfunction

endclass
