class sauria_core_ctrl_status_reg_2 extends uvm_reg;

    `uvm_object_utils(sauria_core_ctrl_status_reg_2)

    uvm_reg_field done_interrupt_en;

    function new(string name="sauria_core_ctrl_status_reg_2");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        done_interrupt_en = uvm_reg_field::type_id::create("core_ctrl_status_done_interrupt_en");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        done_interrupt_en.configure(.parent(this),
                        .size(CORE_CTRL_STATUS_DONE_INT_EN_SIZE),
                        .lsb_pos(CORE_CTRL_STATUS_DONE_INT_EN_LSB),
                        .access(REG_CFG_ACCESS),
                        .volatile(REG_CFG_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
