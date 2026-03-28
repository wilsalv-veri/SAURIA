class sauria_core_weights_cfg_reg_36 extends uvm_reg;

    `uvm_object_utils(sauria_core_weights_cfg_reg_36)

    uvm_reg_field weights_cols_active;
    uvm_reg_field weights_aligned_flag;
    
  
    function new(string name="sauria_core_weights_cfg_reg_36");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        weights_cols_active   = uvm_reg_field::type_id::create("sauria_core_weights_cols_active");
        weights_aligned_flag  = uvm_reg_field::type_id::create("sauria_core_weights_aligned_flag");
    endfunction

    virtual function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        
        super.configure(blk_parent, regfile_parent, hdl_path);
        
        weights_cols_active.configure(.parent(this),
                                    .size(WEI_COLS_ACTIVE_SIZE),
                                    .lsb_pos(WEI_COLS_ACTIVE_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        weights_aligned_flag.configure(.parent(this),
                                    .size(REG_FLAG_SIZE),
                                    .lsb_pos(WEI_ALIGNED_FLAG_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

    
    endfunction

    
endclass