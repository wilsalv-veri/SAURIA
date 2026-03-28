class sauria_core_psums_cfg_reg_40 extends uvm_reg;

    `uvm_object_utils(sauria_core_psums_cfg_reg_40)

    uvm_reg_field psums_tile_cy_step;
    uvm_reg_field psums_tile_ck_lim;
    uvm_reg_field psums_tile_ck_step_lower;
    uvm_reg_field psums_inactive_cols_lower; //Only for INT

    function new(string name="sauria_core_psums_cfg_reg_40");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        psums_tile_cy_step       = uvm_reg_field::type_id::create("sauria_core_psums_tile_cy_step");
        psums_tile_ck_lim        = uvm_reg_field::type_id::create("sauria_core_psums_tile_ck_lim");
        psums_tile_ck_step_lower = uvm_reg_field::type_id::create("sauria_core_psums_tile_ck_step_lower");
        psums_inactive_cols_lower = uvm_reg_field::type_id::create("sauria_core_psums_inactive_cols_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        psums_tile_cy_step.configure(.parent(this),
                            .size(PSUMS_TILE_CY_STEP_SIZE),
                            .lsb_pos(PSUMS_TILE_CY_STEP_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        psums_tile_ck_lim.configure(.parent(this),
                            .size(PSUMS_TILE_DIM_SIZE),
                            .lsb_pos(PSUMS_TILE_CK_LIM_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        if (FP_ARITHMETIC) begin
            psums_tile_ck_step_lower.configure(.parent(this),
                                .size(PSUMS_TILE_CK_STEP_LOWER_SIZE),
                                .lsb_pos(PSUMS_TILE_CK_STEP_LOWER_LSB),
                                .access(REG_CFG_ACCESS),
                                .volatile(REG_CFG_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
        end

        if (INT_ARITHMETIC) begin
            psums_inactive_cols_lower.configure(.parent(this),
                                .size(PSUMS_INACTIVE_COLS_LOWER_SIZE),
                                .lsb_pos(PSUMS_INACTIVE_COLS_LOWER_LSB),
                                .access(REG_CFG_ACCESS),
                                .volatile(REG_CFG_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
        end

    endfunction

endclass
