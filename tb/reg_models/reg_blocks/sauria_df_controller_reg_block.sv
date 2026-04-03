class sauria_df_controller_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_df_controller_reg_block)

    sauria_df_controller_cfg_reg_18 df_controller_cfg_reg_18;
    sauria_df_controller_cfg_reg_19 df_controller_cfg_reg_19;
    sauria_df_controller_cfg_reg_20 df_controller_cfg_reg_20;
    sauria_df_controller_cfg_reg_21 df_controller_cfg_reg_21;

    parameter CFG_REG_18_IDX = 18;
    parameter CFG_REG_19_IDX = 19;
    parameter CFG_REG_20_IDX = 20;
    parameter CFG_REG_21_IDX = 21;

    int first_reg_base_offset;
    int reg_18_base_offset;
    int reg_19_base_offset;
    int reg_20_base_offset;
    int reg_21_base_offset;

    parameter NUM_DF_CONTROLLER_CFG_REGS = 4;

    function new(string name="sauria_df_controller_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        df_controller_cfg_reg_18 = sauria_df_controller_cfg_reg_18::type_id::create("sauria_df_controller_cfg_reg_18");
        df_controller_cfg_reg_19 = sauria_df_controller_cfg_reg_19::type_id::create("sauria_df_controller_cfg_reg_19");
        df_controller_cfg_reg_20 = sauria_df_controller_cfg_reg_20::type_id::create("sauria_df_controller_cfg_reg_20");
        df_controller_cfg_reg_21 = sauria_df_controller_cfg_reg_21::type_id::create("sauria_df_controller_cfg_reg_21");
    endfunction

    virtual function void build_fields();
        df_controller_cfg_reg_18.build_fields();
        df_controller_cfg_reg_19.build_fields();
        df_controller_cfg_reg_20.build_fields();
        df_controller_cfg_reg_21.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");

        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        df_controller_cfg_reg_18.configure(this);
        df_controller_cfg_reg_19.configure(this);
        df_controller_cfg_reg_20.configure(this);
        df_controller_cfg_reg_21.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();

        set_reg_base_addr();

        default_map = create_map("df_controller_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(df_controller_cfg_reg_18, reg_18_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(df_controller_cfg_reg_19, reg_19_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(df_controller_cfg_reg_20, reg_20_base_offset, REG_CFG_ACCESS);
        default_map.add_reg(df_controller_cfg_reg_21, reg_21_base_offset, REG_CFG_ACCESS);

        lock_model();
    endfunction

    virtual function set_reg_base_addr();
        reg_18_base_offset = get_cfg_addr_from_idx(CFG_REG_18_IDX);
        reg_19_base_offset = get_cfg_addr_from_idx(CFG_REG_19_IDX);
        reg_20_base_offset = get_cfg_addr_from_idx(CFG_REG_20_IDX);
        reg_21_base_offset = get_cfg_addr_from_idx(CFG_REG_21_IDX);

        first_reg_base_offset = reg_18_base_offset;
    endfunction

endclass
