class sauria_core_psums_cfg_reg_37 extends uvm_reg;

    `uvm_object_utils(sauria_core_psums_cfg_reg_37)

    uvm_reg_field psums_reps;
    uvm_reg_field psums_cx_lim;
    uvm_reg_field psums_cx_step_lower;

    function new(string name="sauria_core_psums_cfg_reg_37");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        psums_reps          = uvm_reg_field::type_id::create("sauria_core_psums_reps");
        psums_cx_lim        = uvm_reg_field::type_id::create("sauria_core_psums_cx_lim");
        psums_cx_step_lower = uvm_reg_field::type_id::create("sauria_core_psums_cx_step_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        psums_reps.configure(.parent(this),
                            .size(PSUMS_TILE_DIM_SIZE),
                            .lsb_pos(PSUMS_REPS_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        psums_cx_lim.configure(.parent(this),
                            .size(PSUMS_TILE_DIM_SIZE),
                            .lsb_pos(PSUMS_CX_LIM_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        psums_cx_step_lower.configure(.parent(this),
                            .size(PSUMS_CX_STEP_LOWER_SIZE),
                            .lsb_pos(PSUMS_CX_STEP_LOWER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
