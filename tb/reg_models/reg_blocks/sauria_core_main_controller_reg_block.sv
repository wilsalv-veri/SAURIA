class sauria_core_main_controller_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_core_main_controller_reg_block)

    sauria_core_main_controller_cfg_reg_22 core_main_controller_cfg_reg_22;
    sauria_core_main_controller_cfg_reg_23 core_main_controller_cfg_reg_23;

    parameter CFG_REG_22_IDX = 22;
    parameter CFG_REG_23_IDX = 23;

    int first_reg_base_offset;
    int reg_22_base_offset;
    int reg_23_base_offset;

    parameter NUM_CORE_MAIN_CONTROLLER_CFG_REGS = 2;

    function new(string name="sauria_core_main_controller_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        core_main_controller_cfg_reg_22 = sauria_core_main_controller_cfg_reg_22::type_id::create("sauria_core_main_controller_cfg_reg_22");
        core_main_controller_cfg_reg_23 = sauria_core_main_controller_cfg_reg_23::type_id::create("sauria_core_main_controller_cfg_reg_23");
    endfunction

    virtual function void build_fields();
        core_main_controller_cfg_reg_22.build_fields();
        core_main_controller_cfg_reg_23.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");

        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        core_main_controller_cfg_reg_22.configure(this);
        core_main_controller_cfg_reg_23.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();

        set_reg_base_addr();

        default_map = create_map("core_main_controller_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(core_main_controller_cfg_reg_22, reg_22_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_main_controller_cfg_reg_23, reg_23_base_offset, REG_CFG_ACCESS);

        lock_model();
    endfunction

    virtual function set_reg_base_addr();
        reg_22_base_offset = get_cfg_addr_from_idx(CFG_REG_22_IDX);
        reg_23_base_offset = get_cfg_addr_from_idx(CFG_REG_23_IDX);

        first_reg_base_offset = reg_22_base_offset;
    endfunction

endclass
