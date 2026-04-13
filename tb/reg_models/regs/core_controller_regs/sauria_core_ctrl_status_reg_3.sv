class sauria_core_ctrl_status_reg_3 extends uvm_reg;

    `uvm_object_utils(sauria_core_ctrl_status_reg_3)

    uvm_reg_field done_interrupt_status;

    function new(string name="sauria_core_ctrl_status_reg_3");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        done_interrupt_status = uvm_reg_field::type_id::create("core_ctrl_status_done_interrupt_status");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        done_interrupt_status.configure(.parent(this),
                     .size(CORE_CTRL_STATUS_DONE_INT_STATUS_SIZE),
                     .lsb_pos(CORE_CTRL_STATUS_DONE_INT_STATUS_LSB),
                     .access(REG_W1C_ACCESS),
                                 .volatile(REG_STATUS_VOLATILE_VAL),
                                 .reset(REG_CFG_RESET_VAL),
                                 .has_reset(REG_CFG_HAS_RESET),
                                 .is_rand(REG_CFG_IS_RAND),
                                 .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
