class sauria_core_ctrl_status_reg_6 extends uvm_reg;

    `uvm_object_utils(sauria_core_ctrl_status_reg_6)

    uvm_reg_field stalls_counter;

    function new(string name="sauria_core_ctrl_status_reg_6");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        stalls_counter = uvm_reg_field::type_id::create("core_ctrl_status_stalls_counter");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        stalls_counter.configure(.parent(this),
                                 .size(CORE_CTRL_STATUS_STALLS_COUNTER_SIZE),
                                 .lsb_pos(CORE_CTRL_STATUS_STALLS_COUNTER_LSB),
                                 .access(REG_STATUS_ACCESS),
                                 .volatile(REG_STATUS_VOLATILE_VAL),
                                 .reset(REG_CFG_RESET_VAL),
                                 .has_reset(REG_CFG_HAS_RESET),
                                 .is_rand(REG_CFG_IS_RAND),
                                 .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
