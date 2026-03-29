// Status Flags register (offset 0x10)
class sauria_ctrl_status_reg_4 extends uvm_reg;

    `uvm_object_utils(sauria_ctrl_status_reg_4)

    uvm_reg_field status_flags;

    function new(string name="sauria_ctrl_status_reg_4");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        status_flags = uvm_reg_field::type_id::create("ctrl_status_status_flags");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        // Status flags for SAURIA FSMs
        status_flags.configure(.parent(this),
                       .size(CTRL_STATUS_STATUS_FLAGS_SIZE),
                       .lsb_pos(CTRL_STATUS_STATUS_FLAGS_LSB),
                       .access(REG_STATUS_ACCESS),
                       .volatile(REG_STATUS_VOLATILE_VAL),
                       .reset(REG_CFG_RESET_VAL),
                       .has_reset(REG_CFG_HAS_RESET),
                       .is_rand(REG_CFG_IS_RAND),
                       .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
