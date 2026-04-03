class sauria_ctrl_status_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_ctrl_status_reg_block)

    sauria_ctrl_status_reg_0  ctrl_status_reg_0;   // Control & Status  @ 0x000
    sauria_ctrl_status_reg_1  ctrl_status_reg_1;   // Global Int En     @ 0x004
    sauria_ctrl_status_reg_2  ctrl_status_reg_2;   // Done Int En       @ 0x008
    sauria_ctrl_status_reg_3  ctrl_status_reg_3;   // Done Int Status   @ 0x00C
    sauria_ctrl_status_reg_4  ctrl_status_reg_4;   // Status Flags      @ 0x010
    sauria_ctrl_status_reg_5  ctrl_status_reg_5;   // Cycle Counter     @ 0x014
    sauria_ctrl_status_reg_6  ctrl_status_reg_6;   // Stalls Counter    @ 0x018

    function new(string name="sauria_ctrl_status_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        ctrl_status_reg_0 = sauria_ctrl_status_reg_0::type_id::create("sauria_ctrl_status_reg_0");
        ctrl_status_reg_1 = sauria_ctrl_status_reg_1::type_id::create("sauria_ctrl_status_reg_1");
        ctrl_status_reg_2 = sauria_ctrl_status_reg_2::type_id::create("sauria_ctrl_status_reg_2");
        ctrl_status_reg_3 = sauria_ctrl_status_reg_3::type_id::create("sauria_ctrl_status_reg_3");
        ctrl_status_reg_4 = sauria_ctrl_status_reg_4::type_id::create("sauria_ctrl_status_reg_4");
        ctrl_status_reg_5 = sauria_ctrl_status_reg_5::type_id::create("sauria_ctrl_status_reg_5");
        ctrl_status_reg_6 = sauria_ctrl_status_reg_6::type_id::create("sauria_ctrl_status_reg_6");
    endfunction

    virtual function void build_fields();
        ctrl_status_reg_0.build_fields();
        ctrl_status_reg_1.build_fields();
        ctrl_status_reg_2.build_fields();
        ctrl_status_reg_3.build_fields();
        ctrl_status_reg_4.build_fields();
        ctrl_status_reg_5.build_fields();
        ctrl_status_reg_6.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");
        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        ctrl_status_reg_0.configure(this);
        ctrl_status_reg_1.configure(this);
        ctrl_status_reg_2.configure(this);
        ctrl_status_reg_3.configure(this);
        ctrl_status_reg_4.configure(this);
        ctrl_status_reg_5.configure(this);
        ctrl_status_reg_6.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();
        default_map = create_map("ctrl_status_reg_map", CTRL_STATUS_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(ctrl_status_reg_0, CTRL_STATUS_REG_0_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_1, CTRL_STATUS_REG_1_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_2, CTRL_STATUS_REG_2_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_3, CTRL_STATUS_REG_3_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_4, CTRL_STATUS_REG_4_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_5, CTRL_STATUS_REG_5_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_6, CTRL_STATUS_REG_6_ADDR, REG_CFG_ACCESS);

        lock_model();
    endfunction

endclass
