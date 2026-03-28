class sauria_core_ifmaps_cfg_reg_31 extends uvm_reg;

    `uvm_object_utils(sauria_core_ifmaps_cfg_reg_31)

    uvm_reg_field ifmaps_loc_woffs_0;
    uvm_reg_field ifmaps_loc_woffs_1;
    uvm_reg_field ifmaps_loc_woffs_2;
    uvm_reg_field ifmaps_loc_woffs_3;
    uvm_reg_field ifmaps_loc_woffs_4_lower;

    function new(string name="sauria_core_ifmaps_cfg_reg_31");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        ifmaps_loc_woffs_0       = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_0");
        ifmaps_loc_woffs_1       = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_1");
        ifmaps_loc_woffs_2       = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_2");
        ifmaps_loc_woffs_3       = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_3");
        ifmaps_loc_woffs_4_lower = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_4_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        ifmaps_loc_woffs_0.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_0_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_0_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_1.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_1_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_1_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_2.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_2_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_2_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_3.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_3_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_3_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_4_lower.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_4_LOWER_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_4_LOWER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
