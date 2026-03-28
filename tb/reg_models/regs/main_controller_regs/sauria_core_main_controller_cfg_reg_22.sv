class sauria_core_main_controller_cfg_reg_22 extends uvm_reg;

    `uvm_object_utils(sauria_core_main_controller_cfg_reg_22)

    uvm_reg_field total_macs;
    uvm_reg_field act_reps;
    uvm_reg_field weight_reps_lower;

    function new(string name="sauria_core_main_controller_cfg_reg_22");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        total_macs         = uvm_reg_field::type_id::create("sauria_core_total_macs");
        act_reps           = uvm_reg_field::type_id::create("sauria_core_act_reps");
        weight_reps_lower  = uvm_reg_field::type_id::create("sauria_core_weight_reps_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        total_macs.configure(.parent(this),
                            .size(MAIN_CTRL_INC_CNT_LIM_SIZE),
                            .lsb_pos(MAIN_CTRL_INC_CNT_LIM_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        act_reps.configure(.parent(this),
                            .size(MAIN_CTRL_ACT_REPS_SIZE),
                            .lsb_pos(MAIN_CTRL_ACT_REPS_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        weight_reps_lower.configure(.parent(this),
                            .size(MAIN_CTRL_WEIGHT_REPS_LOWER_SIZE),
                            .lsb_pos(MAIN_CTRL_WEIGHT_REPS_LOWER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
