class sauria_core_ifmaps_cfg_reg_32 extends uvm_reg;

    `uvm_object_utils(sauria_core_ifmaps_cfg_reg_32)

    uvm_reg_field ifmaps_loc_woffs_4;
    uvm_reg_field ifmaps_loc_woffs_5;
    uvm_reg_field ifmaps_loc_woffs_6;
    uvm_reg_field ifmaps_loc_woffs_7;

    function new(string name="sauria_core_ifmaps_cfg_reg_32");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        ifmaps_loc_woffs_4 = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_4");
        ifmaps_loc_woffs_5 = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_5");
        ifmaps_loc_woffs_6 = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_6");
        ifmaps_loc_woffs_7 = uvm_reg_field::type_id::create("sauria_core_ifmaps_loc_woffs_7");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        ifmaps_loc_woffs_4.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_4_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_4_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_5.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_5_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_5_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_6.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_6_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_6_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_loc_woffs_7.configure(.parent(this),
                            .size(IFMAPS_LOC_WOFFS_7_SIZE),
                            .lsb_pos(IFMAPS_LOC_WOFFS_7_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
