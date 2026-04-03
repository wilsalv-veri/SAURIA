class sauria_dma_controller_reg_block extends uvm_reg_block;

    `uvm_object_utils(sauria_dma_controller_reg_block)

    sauria_dma_controller_cfg_reg_0  dma_controller_cfg_reg_0;
    sauria_dma_controller_cfg_reg_1  dma_controller_cfg_reg_1;
    sauria_dma_controller_cfg_reg_2  dma_controller_cfg_reg_2;
    sauria_dma_controller_cfg_reg_3  dma_controller_cfg_reg_3;
    sauria_dma_controller_cfg_reg_4  dma_controller_cfg_reg_4;
    sauria_dma_controller_cfg_reg_5  dma_controller_cfg_reg_5;
    sauria_dma_controller_cfg_reg_6  dma_controller_cfg_reg_6;
    sauria_dma_controller_cfg_reg_7  dma_controller_cfg_reg_7;
    sauria_dma_controller_cfg_reg_8  dma_controller_cfg_reg_8;
    sauria_dma_controller_cfg_reg_9  dma_controller_cfg_reg_9;
    sauria_dma_controller_cfg_reg_10 dma_controller_cfg_reg_10;
    sauria_dma_controller_cfg_reg_11 dma_controller_cfg_reg_11;
    sauria_dma_controller_cfg_reg_12 dma_controller_cfg_reg_12;
    sauria_dma_controller_cfg_reg_13 dma_controller_cfg_reg_13;
    sauria_dma_controller_cfg_reg_14 dma_controller_cfg_reg_14;
    sauria_dma_controller_cfg_reg_15 dma_controller_cfg_reg_15;
    sauria_dma_controller_cfg_reg_16 dma_controller_cfg_reg_16;
    sauria_dma_controller_cfg_reg_17 dma_controller_cfg_reg_17;

    parameter CFG_REG_0_IDX  = 0;
    parameter CFG_REG_1_IDX  = 1;
    parameter CFG_REG_2_IDX  = 2;
    parameter CFG_REG_3_IDX  = 3;
    parameter CFG_REG_4_IDX  = 4;
    parameter CFG_REG_5_IDX  = 5;
    parameter CFG_REG_6_IDX  = 6;
    parameter CFG_REG_7_IDX  = 7;
    parameter CFG_REG_8_IDX  = 8;
    parameter CFG_REG_9_IDX  = 9;
    parameter CFG_REG_10_IDX = 10;
    parameter CFG_REG_11_IDX = 11;
    parameter CFG_REG_12_IDX = 12;
    parameter CFG_REG_13_IDX = 13;
    parameter CFG_REG_14_IDX = 14;
    parameter CFG_REG_15_IDX = 15;
    parameter CFG_REG_16_IDX = 16;
    parameter CFG_REG_17_IDX = 17;

    parameter NUM_DMA_CONTROLLER_CFG_REGS = 18;

    function new(string name="sauria_dma_controller_reg_block");
        super.new(name, REG_COVERAGE);
    endfunction

    virtual function void build_regs();
        dma_controller_cfg_reg_0  = sauria_dma_controller_cfg_reg_0::type_id::create("sauria_dma_controller_cfg_reg_0");
        dma_controller_cfg_reg_1  = sauria_dma_controller_cfg_reg_1::type_id::create("sauria_dma_controller_cfg_reg_1");
        dma_controller_cfg_reg_2  = sauria_dma_controller_cfg_reg_2::type_id::create("sauria_dma_controller_cfg_reg_2");
        dma_controller_cfg_reg_3  = sauria_dma_controller_cfg_reg_3::type_id::create("sauria_dma_controller_cfg_reg_3");
        dma_controller_cfg_reg_4  = sauria_dma_controller_cfg_reg_4::type_id::create("sauria_dma_controller_cfg_reg_4");
        dma_controller_cfg_reg_5  = sauria_dma_controller_cfg_reg_5::type_id::create("sauria_dma_controller_cfg_reg_5");
        dma_controller_cfg_reg_6  = sauria_dma_controller_cfg_reg_6::type_id::create("sauria_dma_controller_cfg_reg_6");
        dma_controller_cfg_reg_7  = sauria_dma_controller_cfg_reg_7::type_id::create("sauria_dma_controller_cfg_reg_7");
        dma_controller_cfg_reg_8  = sauria_dma_controller_cfg_reg_8::type_id::create("sauria_dma_controller_cfg_reg_8");
        dma_controller_cfg_reg_9  = sauria_dma_controller_cfg_reg_9::type_id::create("sauria_dma_controller_cfg_reg_9");
        dma_controller_cfg_reg_10 = sauria_dma_controller_cfg_reg_10::type_id::create("sauria_dma_controller_cfg_reg_10");
        dma_controller_cfg_reg_11 = sauria_dma_controller_cfg_reg_11::type_id::create("sauria_dma_controller_cfg_reg_11");
        dma_controller_cfg_reg_12 = sauria_dma_controller_cfg_reg_12::type_id::create("sauria_dma_controller_cfg_reg_12");
        dma_controller_cfg_reg_13 = sauria_dma_controller_cfg_reg_13::type_id::create("sauria_dma_controller_cfg_reg_13");
        dma_controller_cfg_reg_14 = sauria_dma_controller_cfg_reg_14::type_id::create("sauria_dma_controller_cfg_reg_14");
        dma_controller_cfg_reg_15 = sauria_dma_controller_cfg_reg_15::type_id::create("sauria_dma_controller_cfg_reg_15");
        dma_controller_cfg_reg_16 = sauria_dma_controller_cfg_reg_16::type_id::create("sauria_dma_controller_cfg_reg_16");
        dma_controller_cfg_reg_17 = sauria_dma_controller_cfg_reg_17::type_id::create("sauria_dma_controller_cfg_reg_17");
    endfunction

    virtual function void build_fields();
        dma_controller_cfg_reg_0.build_fields();
        dma_controller_cfg_reg_1.build_fields();
        dma_controller_cfg_reg_2.build_fields();
        dma_controller_cfg_reg_3.build_fields();
        dma_controller_cfg_reg_4.build_fields();
        dma_controller_cfg_reg_5.build_fields();
        dma_controller_cfg_reg_6.build_fields();
        dma_controller_cfg_reg_7.build_fields();
        dma_controller_cfg_reg_8.build_fields();
        dma_controller_cfg_reg_9.build_fields();
        dma_controller_cfg_reg_10.build_fields();
        dma_controller_cfg_reg_11.build_fields();
        dma_controller_cfg_reg_12.build_fields();
        dma_controller_cfg_reg_13.build_fields();
        dma_controller_cfg_reg_14.build_fields();
        dma_controller_cfg_reg_15.build_fields();
        dma_controller_cfg_reg_16.build_fields();
        dma_controller_cfg_reg_17.build_fields();
    endfunction

    virtual function void configure(uvm_reg_block parent = null, string hdl_path = "");
        super.configure(parent, hdl_path);

        build_regs();
        build_fields();

        dma_controller_cfg_reg_0.configure(this);
        dma_controller_cfg_reg_1.configure(this);
        dma_controller_cfg_reg_2.configure(this);
        dma_controller_cfg_reg_3.configure(this);
        dma_controller_cfg_reg_4.configure(this);
        dma_controller_cfg_reg_5.configure(this);
        dma_controller_cfg_reg_6.configure(this);
        dma_controller_cfg_reg_7.configure(this);
        dma_controller_cfg_reg_8.configure(this);
        dma_controller_cfg_reg_9.configure(this);
        dma_controller_cfg_reg_10.configure(this);
        dma_controller_cfg_reg_11.configure(this);
        dma_controller_cfg_reg_12.configure(this);
        dma_controller_cfg_reg_13.configure(this);
        dma_controller_cfg_reg_14.configure(this);
        dma_controller_cfg_reg_15.configure(this);
        dma_controller_cfg_reg_16.configure(this);
        dma_controller_cfg_reg_17.configure(this);

        create_mem_map();
    endfunction

    virtual function void create_mem_map();
        default_map = create_map("dma_controller_cfg_map", CFG_BASE_OFFSET,
                                 CFG_AXI_BYTE_NUM, UVM_LITTLE_ENDIAN, 1);

        default_map.add_reg(dma_controller_cfg_reg_0,  get_cfg_addr_from_idx(CFG_REG_0_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_1,  get_cfg_addr_from_idx(CFG_REG_1_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_2,  get_cfg_addr_from_idx(CFG_REG_2_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_3,  get_cfg_addr_from_idx(CFG_REG_3_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_4,  get_cfg_addr_from_idx(CFG_REG_4_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_5,  get_cfg_addr_from_idx(CFG_REG_5_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_6,  get_cfg_addr_from_idx(CFG_REG_6_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_7,  get_cfg_addr_from_idx(CFG_REG_7_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_8,  get_cfg_addr_from_idx(CFG_REG_8_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_9,  get_cfg_addr_from_idx(CFG_REG_9_IDX),  REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_10, get_cfg_addr_from_idx(CFG_REG_10_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_11, get_cfg_addr_from_idx(CFG_REG_11_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_12, get_cfg_addr_from_idx(CFG_REG_12_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_13, get_cfg_addr_from_idx(CFG_REG_13_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_14, get_cfg_addr_from_idx(CFG_REG_14_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_15, get_cfg_addr_from_idx(CFG_REG_15_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_16, get_cfg_addr_from_idx(CFG_REG_16_IDX), REG_CFG_ACCESS);
        default_map.add_reg(dma_controller_cfg_reg_17, get_cfg_addr_from_idx(CFG_REG_17_IDX), REG_CFG_ACCESS);

        lock_model();
    endfunction

endclass
