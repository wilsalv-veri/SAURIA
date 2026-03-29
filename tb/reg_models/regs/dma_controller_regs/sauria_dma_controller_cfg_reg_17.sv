class sauria_dma_controller_cfg_reg_17 extends uvm_reg;

    `uvm_object_utils(sauria_dma_controller_cfg_reg_17)

    uvm_reg_field dma_ifmaps_ett;

    function new(string name="sauria_dma_controller_cfg_reg_17");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        dma_ifmaps_ett = uvm_reg_field::type_id::create("sauria_dma_ifmaps_ett");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);
        
        dma_ifmaps_ett.configure(.parent(this),
                                 .size(DMA_IFMAPS_ETT_SIZE),
                                 .lsb_pos(DMA_IFMAPS_ETT_LSB),
                                 .access(REG_CFG_ACCESS),
                                 .volatile(REG_CFG_VOLATILE_VAL),
                                 .reset(REG_CFG_RESET_VAL),
                                 .has_reset(REG_CFG_HAS_RESET),
                                 .is_rand(REG_CFG_IS_RAND),
                                 .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
