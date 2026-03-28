class sauria_core_psums_cfg_reg_41 extends uvm_reg;

    `uvm_object_utils(sauria_core_psums_cfg_reg_41)

    uvm_reg_field psums_tile_ck_step; //Only for FP
    uvm_reg_field psums_inactive_cols;
    uvm_reg_field psums_preload_en;

    function new(string name="sauria_core_psums_cfg_reg_41");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        psums_tile_ck_step = uvm_reg_field::type_id::create("sauria_core_psums_tile_ck_step");
        psums_inactive_cols = uvm_reg_field::type_id::create("sauria_core_psums_inactive_cols");
        psums_preload_en    = uvm_reg_field::type_id::create("sauria_core_psums_preload_en");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        if (FP_ARITHMETIC) begin
            psums_tile_ck_step.configure(.parent(this),
                                .size(PSUMS_TILE_CK_STEP_SIZE),
                                .lsb_pos(PSUMS_TILE_CK_STEP_LSB),
                                .access(REG_CFG_ACCESS),
                                .volatile(REG_CFG_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
        end

        psums_inactive_cols.configure(.parent(this),
                            .size(PSUMS_INACTIVE_COLS_SIZE),
                            .lsb_pos(PSUMS_INACTIVE_COLS_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        psums_preload_en.configure(.parent(this),
                            .size(REG_FLAG_SIZE),
                            .lsb_pos(PSUMS_PRELOAD_EN_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
