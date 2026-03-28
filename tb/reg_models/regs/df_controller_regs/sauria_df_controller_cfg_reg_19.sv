class sauria_df_controller_cfg_reg_19 extends uvm_reg;

    `uvm_object_utils(sauria_df_controller_cfg_reg_19)

    uvm_reg_field start_sramb_addr;

    function new(string name="sauria_df_controller_cfg_reg_19");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        start_sramb_addr = uvm_reg_field::type_id::create("sauria_df_start_sramb_addr");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);

        start_sramb_addr.configure(.parent(this),
                                .size(DF_START_SRAMB_ADDR_SIZE),
                                .lsb_pos(DF_START_SRAMB_ADDR_LSB),
                                .access(REG_CFG_ACCESS),
                                .volatile(REG_CFG_VOLATILE_VAL),
                                .reset(REG_CFG_RESET_VAL),
                                .has_reset(REG_CFG_HAS_RESET),
                                .is_rand(REG_CFG_IS_RAND),
                                .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    endfunction

endclass
