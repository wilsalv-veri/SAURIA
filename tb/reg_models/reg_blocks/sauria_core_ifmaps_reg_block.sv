class sauria_core_ifmaps_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_core_ifmaps_reg_block)

    sauria_core_ifmaps_cfg_reg_24 core_ifmaps_cfg_reg_24;
    sauria_core_ifmaps_cfg_reg_25 core_ifmaps_cfg_reg_25;
    sauria_core_ifmaps_cfg_reg_26 core_ifmaps_cfg_reg_26;
    sauria_core_ifmaps_cfg_reg_27 core_ifmaps_cfg_reg_27;
    sauria_core_ifmaps_cfg_reg_28 core_ifmaps_cfg_reg_28;
    sauria_core_ifmaps_cfg_reg_29 core_ifmaps_cfg_reg_29;
    sauria_core_ifmaps_cfg_reg_30 core_ifmaps_cfg_reg_30;
    sauria_core_ifmaps_cfg_reg_31 core_ifmaps_cfg_reg_31;
    sauria_core_ifmaps_cfg_reg_32 core_ifmaps_cfg_reg_32;

    parameter CFG_REG_24_IDX = 24;
    parameter CFG_REG_25_IDX = 25;
    parameter CFG_REG_26_IDX = 26;
    parameter CFG_REG_27_IDX = 27;
    parameter CFG_REG_28_IDX = 28;
    parameter CFG_REG_29_IDX = 29;
    parameter CFG_REG_30_IDX = 30;
    parameter CFG_REG_31_IDX = 31;
    parameter CFG_REG_32_IDX = 32;

    int first_reg_base_offset;
    int reg_24_base_offset;
    int reg_25_base_offset;
    int reg_26_base_offset;
    int reg_27_base_offset;
    int reg_28_base_offset;
    int reg_29_base_offset;
    int reg_30_base_offset;
    int reg_31_base_offset;
    int reg_32_base_offset;

    parameter NUM_CORE_IFMAPS_CFG_REGS = 9;

    function new(string name="sauria_core_ifmaps_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        core_ifmaps_cfg_reg_24 = sauria_core_ifmaps_cfg_reg_24::type_id::create("sauria_core_ifmaps_cfg_reg_24");
        core_ifmaps_cfg_reg_25 = sauria_core_ifmaps_cfg_reg_25::type_id::create("sauria_core_ifmaps_cfg_reg_25");
        core_ifmaps_cfg_reg_26 = sauria_core_ifmaps_cfg_reg_26::type_id::create("sauria_core_ifmaps_cfg_reg_26");
        core_ifmaps_cfg_reg_27 = sauria_core_ifmaps_cfg_reg_27::type_id::create("sauria_core_ifmaps_cfg_reg_27");
        core_ifmaps_cfg_reg_28 = sauria_core_ifmaps_cfg_reg_28::type_id::create("sauria_core_ifmaps_cfg_reg_28");
        core_ifmaps_cfg_reg_29 = sauria_core_ifmaps_cfg_reg_29::type_id::create("sauria_core_ifmaps_cfg_reg_29");
        core_ifmaps_cfg_reg_30 = sauria_core_ifmaps_cfg_reg_30::type_id::create("sauria_core_ifmaps_cfg_reg_30");
        core_ifmaps_cfg_reg_31 = sauria_core_ifmaps_cfg_reg_31::type_id::create("sauria_core_ifmaps_cfg_reg_31");
        core_ifmaps_cfg_reg_32 = sauria_core_ifmaps_cfg_reg_32::type_id::create("sauria_core_ifmaps_cfg_reg_32");
    endfunction

    virtual function void build_fields();
        core_ifmaps_cfg_reg_24.build_fields();
        core_ifmaps_cfg_reg_25.build_fields();
        core_ifmaps_cfg_reg_26.build_fields();
        core_ifmaps_cfg_reg_27.build_fields();
        core_ifmaps_cfg_reg_28.build_fields();
        core_ifmaps_cfg_reg_29.build_fields();
        core_ifmaps_cfg_reg_30.build_fields();
        core_ifmaps_cfg_reg_31.build_fields();
        core_ifmaps_cfg_reg_32.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");

        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        core_ifmaps_cfg_reg_24.configure(this);
        core_ifmaps_cfg_reg_25.configure(this);
        core_ifmaps_cfg_reg_26.configure(this);
        core_ifmaps_cfg_reg_27.configure(this);
        core_ifmaps_cfg_reg_28.configure(this);
        core_ifmaps_cfg_reg_29.configure(this);
        core_ifmaps_cfg_reg_30.configure(this);
        core_ifmaps_cfg_reg_31.configure(this);
        core_ifmaps_cfg_reg_32.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();

        set_reg_base_addr();

        default_map = create_map("core_ifmaps_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(core_ifmaps_cfg_reg_24, reg_24_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_25, reg_25_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_26, reg_26_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_27, reg_27_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_28, reg_28_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_29, reg_29_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_30, reg_30_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_31, reg_31_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_ifmaps_cfg_reg_32, reg_32_base_offset, REG_CFG_ACCESS);

        lock_model();
    endfunction

    virtual function set_reg_base_addr();
        reg_24_base_offset = get_cfg_addr_from_idx(CFG_REG_24_IDX);
        reg_25_base_offset = get_cfg_addr_from_idx(CFG_REG_25_IDX);
        reg_26_base_offset = get_cfg_addr_from_idx(CFG_REG_26_IDX);
        reg_27_base_offset = get_cfg_addr_from_idx(CFG_REG_27_IDX);
        reg_28_base_offset = get_cfg_addr_from_idx(CFG_REG_28_IDX);
        reg_29_base_offset = get_cfg_addr_from_idx(CFG_REG_29_IDX);
        reg_30_base_offset = get_cfg_addr_from_idx(CFG_REG_30_IDX);
        reg_31_base_offset = get_cfg_addr_from_idx(CFG_REG_31_IDX);
        reg_32_base_offset = get_cfg_addr_from_idx(CFG_REG_32_IDX);

        first_reg_base_offset = reg_24_base_offset;
    endfunction

endclass
