class sauria_core_psums_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_core_psums_reg_block)

    sauria_core_psums_cfg_reg_37 core_psums_cfg_reg_37;
    sauria_core_psums_cfg_reg_38 core_psums_cfg_reg_38;
    sauria_core_psums_cfg_reg_39 core_psums_cfg_reg_39;
    sauria_core_psums_cfg_reg_40 core_psums_cfg_reg_40;
    sauria_core_psums_cfg_reg_41 core_psums_cfg_reg_41;

    parameter CFG_REG_37_IDX = 37;
    parameter CFG_REG_38_IDX = 38;
    parameter CFG_REG_39_IDX = 39;
    parameter CFG_REG_40_IDX = 40;
    parameter CFG_REG_41_IDX = 41;

    int first_reg_base_offset;
    int reg_37_base_offset;
    int reg_38_base_offset;
    int reg_39_base_offset;
    int reg_40_base_offset;
    int reg_41_base_offset;

    parameter NUM_CORE_PSUMS_CFG_REGS = 5;

    function new(string name="sauria_core_psums_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        core_psums_cfg_reg_37 = sauria_core_psums_cfg_reg_37::type_id::create("sauria_core_psums_cfg_reg_37");
        core_psums_cfg_reg_38 = sauria_core_psums_cfg_reg_38::type_id::create("sauria_core_psums_cfg_reg_38");
        core_psums_cfg_reg_39 = sauria_core_psums_cfg_reg_39::type_id::create("sauria_core_psums_cfg_reg_39");
        core_psums_cfg_reg_40 = sauria_core_psums_cfg_reg_40::type_id::create("sauria_core_psums_cfg_reg_40");
        core_psums_cfg_reg_41 = sauria_core_psums_cfg_reg_41::type_id::create("sauria_core_psums_cfg_reg_41");
    endfunction

    virtual function void build_fields();
        core_psums_cfg_reg_37.build_fields();
        core_psums_cfg_reg_38.build_fields();
        core_psums_cfg_reg_39.build_fields();
        core_psums_cfg_reg_40.build_fields();
        core_psums_cfg_reg_41.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");

        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        core_psums_cfg_reg_37.configure(this);
        core_psums_cfg_reg_38.configure(this);
        core_psums_cfg_reg_39.configure(this);
        core_psums_cfg_reg_40.configure(this);
        core_psums_cfg_reg_41.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();

        set_reg_base_addr();

        default_map = create_map("core_psums_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_DATA_WIDTH_BYTES, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(core_psums_cfg_reg_37, reg_37_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_psums_cfg_reg_38, reg_38_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_psums_cfg_reg_39, reg_39_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_psums_cfg_reg_40, reg_40_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_psums_cfg_reg_41, reg_41_base_offset, REG_CFG_ACCESS);

        lock_model();
    endfunction

    virtual function set_reg_base_addr();
        reg_37_base_offset = get_cfg_addr_from_idx(CFG_REG_37_IDX);
        reg_38_base_offset = get_cfg_addr_from_idx(CFG_REG_38_IDX);
        reg_39_base_offset = get_cfg_addr_from_idx(CFG_REG_39_IDX);
        reg_40_base_offset = get_cfg_addr_from_idx(CFG_REG_40_IDX);
        reg_41_base_offset = get_cfg_addr_from_idx(CFG_REG_41_IDX);

        first_reg_base_offset = reg_37_base_offset;
    endfunction

endclass
