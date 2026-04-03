class sauria_core_weights_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_core_weights_reg_block)

    sauria_core_weights_cfg_reg_33 core_weights_cfg_reg_33;
    sauria_core_weights_cfg_reg_34 core_weights_cfg_reg_34;
    sauria_core_weights_cfg_reg_35 core_weights_cfg_reg_35;
    sauria_core_weights_cfg_reg_36 core_weights_cfg_reg_36;

    parameter CFG_REG_33_IDX = 33;
    parameter CFG_REG_34_IDX = 34;
    parameter CFG_REG_35_IDX = 35;
    parameter CFG_REG_36_IDX = 36;
    
    int first_reg_base_offset;
    int reg_33_base_offset;
    int reg_34_base_offset;
    int reg_35_base_offset;
    int reg_36_base_offset;
    
    parameter NUM_CORE_WEI_CFG_REGS = 4;

    function new(string name="sauria_core_weights_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        core_weights_cfg_reg_33 = sauria_core_weights_cfg_reg_33::type_id::create("sauria_core_weights_cfg_reg_33");
        core_weights_cfg_reg_34 = sauria_core_weights_cfg_reg_34::type_id::create("sauria_core_weights_cfg_reg_34");
        core_weights_cfg_reg_35 = sauria_core_weights_cfg_reg_35::type_id::create("sauria_core_weights_cfg_reg_35");
        core_weights_cfg_reg_36 = sauria_core_weights_cfg_reg_36::type_id::create("sauria_core_weights_cfg_reg_36");
    endfunction

    virtual function void build_fields();
        core_weights_cfg_reg_33.build_fields();
        core_weights_cfg_reg_34.build_fields();
        core_weights_cfg_reg_35.build_fields();
        core_weights_cfg_reg_36.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");

        super.configure(parent, hdl_path);

        build_regs();
        build_fields();
        
        core_weights_cfg_reg_33.configure(this);
        core_weights_cfg_reg_34.configure(this);
        core_weights_cfg_reg_35.configure(this);
        core_weights_cfg_reg_36.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();

        set_reg_base_addr();

        default_map = create_map("core_weights_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);
                        
        default_map.add_reg(core_weights_cfg_reg_33, reg_33_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_weights_cfg_reg_34, reg_34_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_weights_cfg_reg_35, reg_35_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(core_weights_cfg_reg_36, reg_36_base_offset, REG_CFG_ACCESS);
        
        lock_model();
    endfunction

    virtual function set_reg_base_addr();
        reg_33_base_offset = get_cfg_addr_from_idx(CFG_REG_33_IDX);
        reg_34_base_offset = get_cfg_addr_from_idx(CFG_REG_34_IDX);
        reg_35_base_offset = get_cfg_addr_from_idx(CFG_REG_35_IDX);
        reg_36_base_offset = get_cfg_addr_from_idx(CFG_REG_36_IDX);

        first_reg_base_offset = reg_33_base_offset;
    endfunction

endclass