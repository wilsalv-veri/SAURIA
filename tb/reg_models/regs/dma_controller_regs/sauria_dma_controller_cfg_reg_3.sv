class sauria_dma_controller_cfg_reg_3 extends uvm_reg;

    `uvm_object_utils(sauria_dma_controller_cfg_reg_3)

    uvm_reg_field dma_tile_psums_y_step;

    function new(string name="sauria_dma_controller_cfg_reg_3");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        dma_tile_psums_y_step = uvm_reg_field::type_id::create("sauria_dma_tile_psums_y_step");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

            dma_tile_psums_y_step.configure(.parent(this),
                                            .size(DMA_TILE_PSUMS_Y_STEP_SIZE),
                                            .lsb_pos(DMA_TILE_PSUMS_Y_STEP_LSB),
                                            .access(REG_CFG_ACCESS),
                                            .volatile(REG_CFG_VOLATILE_VAL),
                                            .reset(REG_CFG_RESET_VAL),
                                            .has_reset(REG_CFG_HAS_RESET),
                                            .is_rand(REG_CFG_IS_RAND),
                                            .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
