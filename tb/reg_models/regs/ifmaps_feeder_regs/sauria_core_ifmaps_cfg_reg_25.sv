class sauria_core_ifmaps_cfg_reg_25 extends uvm_reg;

    `uvm_object_utils(sauria_core_ifmaps_cfg_reg_25)

    uvm_reg_field ifmaps_y_lim;
    uvm_reg_field ifmaps_y_step;
    uvm_reg_field ifmaps_ch_lim_lower;

    function new(string name="sauria_core_ifmaps_cfg_reg_25");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        ifmaps_y_lim      = uvm_reg_field::type_id::create("sauria_core_ifmaps_y_lim");
        ifmaps_y_step     = uvm_reg_field::type_id::create("sauria_core_ifmaps_y_step");
        ifmaps_ch_lim_lower = uvm_reg_field::type_id::create("sauria_core_ifmaps_ch_lim_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        ifmaps_y_lim.configure(.parent(this),
                            .size(IFMAPS_Y_LIM_SIZE),
                            .lsb_pos(IFMAPS_Y_LIM_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_y_step.configure(.parent(this),
                            .size(ACT_TILE_DIM_SIZE),
                            .lsb_pos(IFMAPS_Y_STEP_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ifmaps_ch_lim_lower.configure(.parent(this),
                            .size(IFMAPS_CH_LIM_LOWER_SIZE),
                            .lsb_pos(IFMAPS_CH_LIM_LOWER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
