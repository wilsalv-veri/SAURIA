class sauria_core_ctrl_status_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_core_ctrl_status_reg_block)

    sauria_core_ctrl_status_reg_0 core_ctrl_status_reg_0;
    sauria_core_ctrl_status_reg_1 core_ctrl_status_reg_1;
    sauria_core_ctrl_status_reg_2 core_ctrl_status_reg_2;
    sauria_core_ctrl_status_reg_3 core_ctrl_status_reg_3;
    sauria_core_ctrl_status_reg_4 core_ctrl_status_reg_4;
    sauria_core_ctrl_status_reg_5 core_ctrl_status_reg_5;
    sauria_core_ctrl_status_reg_6 core_ctrl_status_reg_6;

    function new(string name="sauria_core_ctrl_status_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        core_ctrl_status_reg_0 = sauria_core_ctrl_status_reg_0::type_id::create("sauria_core_ctrl_status_reg_0");
        core_ctrl_status_reg_1 = sauria_core_ctrl_status_reg_1::type_id::create("sauria_core_ctrl_status_reg_1");
        core_ctrl_status_reg_2 = sauria_core_ctrl_status_reg_2::type_id::create("sauria_core_ctrl_status_reg_2");
        core_ctrl_status_reg_3 = sauria_core_ctrl_status_reg_3::type_id::create("sauria_core_ctrl_status_reg_3");
        core_ctrl_status_reg_4 = sauria_core_ctrl_status_reg_4::type_id::create("sauria_core_ctrl_status_reg_4");
        core_ctrl_status_reg_5 = sauria_core_ctrl_status_reg_5::type_id::create("sauria_core_ctrl_status_reg_5");
        core_ctrl_status_reg_6 = sauria_core_ctrl_status_reg_6::type_id::create("sauria_core_ctrl_status_reg_6");
    endfunction

    virtual function void build_fields();
        core_ctrl_status_reg_0.build_fields();
        core_ctrl_status_reg_1.build_fields();
        core_ctrl_status_reg_2.build_fields();
        core_ctrl_status_reg_3.build_fields();
        core_ctrl_status_reg_4.build_fields();
        core_ctrl_status_reg_5.build_fields();
        core_ctrl_status_reg_6.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");
        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        core_ctrl_status_reg_0.configure(this);
        core_ctrl_status_reg_1.configure(this);
        core_ctrl_status_reg_2.configure(this);
        core_ctrl_status_reg_3.configure(this);
        core_ctrl_status_reg_4.configure(this);
        core_ctrl_status_reg_5.configure(this);
        core_ctrl_status_reg_6.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();
        default_map = create_map("core_ctrl_status_reg_map", CORE_CTRL_STATUS_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(core_ctrl_status_reg_0, CORE_CTRL_STATUS_REG_0_ADDR, REG_STATUS_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_1, CORE_CTRL_STATUS_REG_1_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_2, CORE_CTRL_STATUS_REG_2_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_3, CORE_CTRL_STATUS_REG_3_ADDR, REG_W1T_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_4, CORE_CTRL_STATUS_REG_4_ADDR, REG_STATUS_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_5, CORE_CTRL_STATUS_REG_5_ADDR, REG_STATUS_ACCESS);
        default_map.add_reg(core_ctrl_status_reg_6, CORE_CTRL_STATUS_REG_6_ADDR, REG_STATUS_ACCESS);

        lock_model();
    endfunction

endclass
