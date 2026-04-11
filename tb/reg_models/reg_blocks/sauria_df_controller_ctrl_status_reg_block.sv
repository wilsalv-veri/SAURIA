class sauria_df_controller_ctrl_status_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_df_controller_ctrl_status_reg_block)

    sauria_df_controller_ctrl_status_reg_0  ctrl_status_reg_0;   // Control & Status  @ 0x000
    sauria_df_controller_ctrl_status_reg_1  ctrl_status_reg_1;   // Global Int En     @ 0x004
    sauria_df_controller_ctrl_status_reg_2  ctrl_status_reg_2;   // Done Int En       @ 0x008

    function new(string name="sauria_df_controller_ctrl_status_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        ctrl_status_reg_0 = sauria_df_controller_ctrl_status_reg_0::type_id::create("sauria_df_controller_ctrl_status_reg_0");
        ctrl_status_reg_1 = sauria_df_controller_ctrl_status_reg_1::type_id::create("sauria_df_controller_ctrl_status_reg_1");
        ctrl_status_reg_2 = sauria_df_controller_ctrl_status_reg_2::type_id::create("sauria_df_controller_ctrl_status_reg_2");
    endfunction

    virtual function void build_fields();
        ctrl_status_reg_0.build_fields();
        ctrl_status_reg_1.build_fields();
        ctrl_status_reg_2.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");
        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        ctrl_status_reg_0.configure(this);
        ctrl_status_reg_1.configure(this);
        ctrl_status_reg_2.configure(this);
        create_mem_map();
    endfunction

    virtual function void create_mem_map();
        default_map = create_map("df_controller_ctrl_status_reg_map", DF_CONTROLLER_CTRL_STATUS_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(ctrl_status_reg_0, DF_CONTROLLER_CTRL_STATUS_REG_0_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_1, DF_CONTROLLER_CTRL_STATUS_REG_1_ADDR, REG_CFG_ACCESS);
        default_map.add_reg(ctrl_status_reg_2, DF_CONTROLLER_CTRL_STATUS_REG_2_ADDR, REG_CFG_ACCESS);

        lock_model();
    endfunction

endclass
