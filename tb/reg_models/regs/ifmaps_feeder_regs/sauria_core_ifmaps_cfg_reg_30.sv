class sauria_core_ifmaps_cfg_reg_30 extends uvm_reg;

    `uvm_object_utils(sauria_core_ifmaps_cfg_reg_30)

    uvm_reg_field dilation_pattern_upper;
    uvm_reg_field ifmaps_rows_active;
    uvm_reg_field ifmaps_loc_woffs_0_lower;

    function new(string name="sauria_core_ifmaps_cfg_reg_30");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        dilation_pattern_upper = uvm_reg_field::type_id::create("sauria_core_ifmaps_dilation_pattern_upper");
        ifmaps_rows_active      = uvm_reg_field::type_id::create("sauria_core_ifmaps_rows_active");
        ifmaps_loc_woffs_0_lower = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_0_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        dilation_pattern_upper.configure(.parent(this),
                            .size(IFMAPS_DILATION_PATTERN_UPPER_SIZE),
                            .lsb_pos(IFMAPS_DILATION_PATTERN_UPPER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_rows_active.configure(.parent(this),
                            .size(IFMAPS_ROWS_ACTIVE_SIZE),
                            .lsb_pos(IFMAPS_ROWS_ACTIVE_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_0_lower.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_0_LOWER_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_0_LOWER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
