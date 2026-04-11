class sauria_core_ctrl_status_reg_5 extends uvm_reg;

    `uvm_object_utils(sauria_core_ctrl_status_reg_5)

    uvm_reg_field cycle_counter;

    function new(string name="sauria_core_ctrl_status_reg_5");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        cycle_counter = uvm_reg_field::type_id::create("core_ctrl_status_cycle_counter");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        cycle_counter.configure(.parent(this),
                                .size(CORE_CTRL_STATUS_CYCLE_COUNTER_SIZE),
                                .lsb_pos(CORE_CTRL_STATUS_CYCLE_COUNTER_LSB),
                                .access(REG_STATUS_ACCESS),
                                .volatile(REG_STATUS_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
