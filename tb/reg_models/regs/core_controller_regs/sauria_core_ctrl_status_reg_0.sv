class sauria_core_ctrl_status_reg_0 extends uvm_reg;

    `uvm_object_utils(sauria_core_ctrl_status_reg_0)

    uvm_reg_field start;
    uvm_reg_field done;
    uvm_reg_field idle;
    uvm_reg_field ready;
    uvm_reg_field auto_restart;
    uvm_reg_field memory_switch;
    uvm_reg_field mem_keep_A;
    uvm_reg_field mem_keep_B;
    uvm_reg_field mem_keep_C;
    uvm_reg_field implicit_map;
    uvm_reg_field soft_reset;

    function new(string name="sauria_core_ctrl_status_reg_0");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        start         = uvm_reg_field::type_id::create("core_ctrl_status_start");
        done          = uvm_reg_field::type_id::create("core_ctrl_status_done");
        idle          = uvm_reg_field::type_id::create("core_ctrl_status_idle");
        ready         = uvm_reg_field::type_id::create("core_ctrl_status_ready");
        auto_restart  = uvm_reg_field::type_id::create("core_ctrl_status_auto_restart");
        memory_switch = uvm_reg_field::type_id::create("core_ctrl_status_memory_switch");
        mem_keep_A    = uvm_reg_field::type_id::create("core_ctrl_status_mem_keep_A");
        mem_keep_B    = uvm_reg_field::type_id::create("core_ctrl_status_mem_keep_B");
        mem_keep_C    = uvm_reg_field::type_id::create("core_ctrl_status_mem_keep_C");
        implicit_map  = uvm_reg_field::type_id::create("core_ctrl_status_implicit_map");
        soft_reset    = uvm_reg_field::type_id::create("core_ctrl_status_soft_reset");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        start.configure(.parent(this),
                .size(CORE_CTRL_STATUS_START_SIZE),
                .lsb_pos(CORE_CTRL_STATUS_START_LSB),
                .access(REG_CFG_ACCESS),
                .volatile(REG_CFG_VOLATILE_VAL),
                .reset(REG_CFG_RESET_VAL),
                .has_reset(REG_CFG_HAS_RESET),
                .is_rand(REG_CFG_IS_RAND),
                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        done.configure(.parent(this),
                   .size(CORE_CTRL_STATUS_DONE_SIZE),
                   .lsb_pos(CORE_CTRL_STATUS_DONE_LSB),
                   .access(REG_W1C_ACCESS),
                   .volatile(REG_STATUS_VOLATILE_VAL),
                   .reset(REG_CFG_RESET_VAL),
                   .has_reset(REG_CFG_HAS_RESET),
                   .is_rand(REG_CFG_IS_RAND),
                   .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        idle.configure(.parent(this),
                   .size(CORE_CTRL_STATUS_IDLE_SIZE),
                   .lsb_pos(CORE_CTRL_STATUS_IDLE_LSB),
                       .access(REG_STATUS_ACCESS),
                       .volatile(REG_STATUS_VOLATILE_VAL),
                       .reset(REG_CFG_RESET_VAL),
                       .has_reset(REG_CFG_HAS_RESET),
                       .is_rand(REG_CFG_IS_RAND),
                       .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        ready.configure(.parent(this),
                .size(CORE_CTRL_STATUS_READY_SIZE),
                .lsb_pos(CORE_CTRL_STATUS_READY_LSB),
                .access(REG_STATUS_ACCESS),
                .volatile(REG_STATUS_VOLATILE_VAL),
                .reset(REG_CFG_RESET_VAL),
                .has_reset(REG_CFG_HAS_RESET),
                .is_rand(REG_CFG_IS_RAND),
                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        auto_restart.configure(.parent(this),
                       .size(CORE_CTRL_STATUS_AUTO_RESTART_SIZE),
                       .lsb_pos(CORE_CTRL_STATUS_AUTO_RESTART_LSB),
                       .access(REG_CFG_ACCESS),
                       .volatile(REG_CFG_VOLATILE_VAL),
                       .reset(REG_CFG_RESET_VAL),
                       .has_reset(REG_CFG_HAS_RESET),
                       .is_rand(REG_CFG_IS_RAND),
                       .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        memory_switch.configure(.parent(this),
                    .size(CORE_CTRL_STATUS_MEM_SWITCH_SIZE),
                    .lsb_pos(CORE_CTRL_STATUS_MEM_SWITCH_LSB),
                    .access(REG_CFG_ACCESS),
                    .volatile(REG_CFG_VOLATILE_VAL),
                    .reset(REG_CFG_RESET_VAL),
                    .has_reset(REG_CFG_HAS_RESET),
                    .is_rand(REG_CFG_IS_RAND),
                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        mem_keep_A.configure(.parent(this),
                     .size(CORE_CTRL_STATUS_MEM_KEEP_A_SIZE),
                     .lsb_pos(CORE_CTRL_STATUS_MEM_KEEP_A_LSB),
                     .access(REG_CFG_ACCESS),
                     .volatile(REG_CFG_VOLATILE_VAL),
                     .reset(REG_CFG_RESET_VAL),
                     .has_reset(REG_CFG_HAS_RESET),
                     .is_rand(REG_CFG_IS_RAND),
                     .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        mem_keep_B.configure(.parent(this),
                     .size(CORE_CTRL_STATUS_MEM_KEEP_B_SIZE),
                     .lsb_pos(CORE_CTRL_STATUS_MEM_KEEP_B_LSB),
                     .access(REG_CFG_ACCESS),
                     .volatile(REG_CFG_VOLATILE_VAL),
                     .reset(REG_CFG_RESET_VAL),
                     .has_reset(REG_CFG_HAS_RESET),
                     .is_rand(REG_CFG_IS_RAND),
                     .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        mem_keep_C.configure(.parent(this),
                     .size(CORE_CTRL_STATUS_MEM_KEEP_C_SIZE),
                     .lsb_pos(CORE_CTRL_STATUS_MEM_KEEP_C_LSB),
                     .access(REG_CFG_ACCESS),
                     .volatile(REG_CFG_VOLATILE_VAL),
                     .reset(REG_CFG_RESET_VAL),
                     .has_reset(REG_CFG_HAS_RESET),
                     .is_rand(REG_CFG_IS_RAND),
                     .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        implicit_map.configure(.parent(this),
                       .size(CORE_CTRL_STATUS_IMPLICIT_MAP_SIZE),
                       .lsb_pos(CORE_CTRL_STATUS_IMPLICIT_MAP_LSB),
                       .access(REG_CFG_ACCESS),
                       .volatile(REG_CFG_VOLATILE_VAL),
                       .reset(REG_CFG_RESET_VAL),
                       .has_reset(REG_CFG_HAS_RESET),
                       .is_rand(REG_CFG_IS_RAND),
                       .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        soft_reset.configure(.parent(this),
                     .size(CORE_CTRL_STATUS_SOFT_RESET_SIZE),
                     .lsb_pos(CORE_CTRL_STATUS_SOFT_RESET_LSB),
                     .access(REG_CFG_ACCESS),
                     .volatile(REG_CFG_VOLATILE_VAL),
                     .reset(REG_CFG_RESET_VAL),
                     .has_reset(REG_CFG_HAS_RESET),
                     .is_rand(REG_CFG_IS_RAND),
                     .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
