class sauria_core_main_controller_cfg_reg_23 extends uvm_reg;

    `uvm_object_utils(sauria_core_main_controller_cfg_reg_23)

    uvm_reg_field weight_reps_upper;
    uvm_reg_field zero_negligence_threshold;

    function new(string name="sauria_core_main_controller_cfg_reg_23");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        weight_reps_upper         = uvm_reg_field::type_id::create("sauria_core_weight_reps_upper");
        zero_negligence_threshold = uvm_reg_field::type_id::create("sauria_core_zero_negligence_threshold");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        weight_reps_upper.configure(.parent(this),
                            .size(MAIN_CTRL_WEIGHT_REPS_UPPER_SIZE),
                            .lsb_pos(MAIN_CTRL_WEIGHT_REPS_UPPER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        zero_negligence_threshold.configure(.parent(this),
                            .size(MAIN_CTRL_ZERO_NEGLIGENCE_SIZE),
                            .lsb_pos(MAIN_CTRL_ZERO_NEGLIGENCE_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
