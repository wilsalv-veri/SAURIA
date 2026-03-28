class sauria_core_ifmaps_cfg_reg_29 extends uvm_reg;

    `uvm_object_utils(sauria_core_ifmaps_cfg_reg_29)

    uvm_reg_field dilation_pattern_second_byte;

    function new(string name="sauria_core_ifmaps_cfg_reg_29");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        dilation_pattern_second_byte = uvm_reg_field::type_id::create("sauria_core_ifmaps_dilation_pattern_second_byte");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        dilation_pattern_second_byte.configure(.parent(this),
                            .size(IFMAPS_DILATION_PATTERN_2ND_BYTE_SIZE),
                            .lsb_pos(IFMAPS_DILATION_PATTERN_2ND_BYTE_LSB),
                            .access(REG_CFG_ACCESS),
                            .volatile(REG_CFG_VOLATILE_VAL),
                            .reset(REG_CFG_RESET_VAL),
                            .has_reset(REG_CFG_HAS_RESET),
                            .is_rand(REG_CFG_IS_RAND),
                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
