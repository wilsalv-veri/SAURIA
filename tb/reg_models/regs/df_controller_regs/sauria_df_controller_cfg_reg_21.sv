class sauria_df_controller_cfg_reg_21 extends uvm_reg;

    `uvm_object_utils(sauria_df_controller_cfg_reg_21)

    uvm_reg_field loop_order;
    uvm_reg_field stand_alone;
    uvm_reg_field stand_alone_keep_a;
    uvm_reg_field stand_alone_keep_b;
    uvm_reg_field stand_alone_keep_c;
    uvm_reg_field start;
    uvm_reg_field cw_eq;
    uvm_reg_field ch_eq;
    uvm_reg_field ck_eq;
    uvm_reg_field wxfer_op;

    function new(string name="sauria_df_controller_cfg_reg_21");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        loop_order        = uvm_reg_field::type_id::create("sauria_df_loop_order");
        stand_alone       = uvm_reg_field::type_id::create("sauria_df_stand_alone");
        stand_alone_keep_a = uvm_reg_field::type_id::create("sauria_df_stand_alone_keep_a");
        stand_alone_keep_b = uvm_reg_field::type_id::create("sauria_df_stand_alone_keep_b");
        stand_alone_keep_c = uvm_reg_field::type_id::create("sauria_df_stand_alone_keep_c");
        start             = uvm_reg_field::type_id::create("sauria_df_start");
        cw_eq             = uvm_reg_field::type_id::create("sauria_df_cw_eq");
        ch_eq             = uvm_reg_field::type_id::create("sauria_df_ch_eq");
        ck_eq             = uvm_reg_field::type_id::create("sauria_df_ck_eq");
        wxfer_op          = uvm_reg_field::type_id::create("sauria_df_wxfer_op");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        loop_order.configure(.parent(this),
                            .size(DF_LOOP_ORDER_SIZE),
                            .lsb_pos(DF_LOOP_ORDER_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        stand_alone.configure(.parent(this),
                            .size(REG_FLAG_SIZE),
                            .lsb_pos(DF_STAND_ALONE_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        stand_alone_keep_a.configure(.parent(this),
                                    .size(REG_FLAG_SIZE),
                                    .lsb_pos(DF_STAND_ALONE_KEEP_A_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        stand_alone_keep_b.configure(.parent(this),
                                    .size(REG_FLAG_SIZE),
                                    .lsb_pos(DF_STAND_ALONE_KEEP_B_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        stand_alone_keep_c.configure(.parent(this),
                                    .size(REG_FLAG_SIZE),
                                    .lsb_pos(DF_STAND_ALONE_KEEP_C_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        start.configure(.parent(this),
                        .size(REG_FLAG_SIZE),
                        .lsb_pos(DF_START_LSB),
                        .access(REG_CFG_ACCESS),
                        .volatile(REG_CFG_VOLATILE_VAL),
                        .reset(REG_CFG_RESET_VAL),
                        .has_reset(REG_CFG_HAS_RESET),
                        .is_rand(REG_CFG_IS_RAND),
                        .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        cw_eq.configure(.parent(this),
                        .size(REG_FLAG_SIZE),
                        .lsb_pos(DF_CW_EQ_LSB),
                        .access(REG_CFG_ACCESS),
                        .volatile(REG_CFG_VOLATILE_VAL),
                        .reset(REG_CFG_RESET_VAL),
                        .has_reset(REG_CFG_HAS_RESET),
                        .is_rand(REG_CFG_IS_RAND),
                        .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ch_eq.configure(.parent(this),
                        .size(REG_FLAG_SIZE),
                        .lsb_pos(DF_CH_EQ_LSB),
                        .access(REG_CFG_ACCESS),
                        .volatile(REG_CFG_VOLATILE_VAL),
                        .reset(REG_CFG_RESET_VAL),
                        .has_reset(REG_CFG_HAS_RESET),
                        .is_rand(REG_CFG_IS_RAND),
                        .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ck_eq.configure(.parent(this),
                        .size(REG_FLAG_SIZE),
                        .lsb_pos(DF_CK_EQ_LSB),
                        .access(REG_CFG_ACCESS),
                        .volatile(REG_CFG_VOLATILE_VAL),
                        .reset(REG_CFG_RESET_VAL),
                        .has_reset(REG_CFG_HAS_RESET),
                        .is_rand(REG_CFG_IS_RAND),
                        .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        wxfer_op.configure(.parent(this),
                            .size(REG_FLAG_SIZE),
                            .lsb_pos(DF_WXFER_OP_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
