class sauria_dma_controller_cfg_reg_1 extends uvm_reg;

    `uvm_object_utils(sauria_dma_controller_cfg_reg_1)

    uvm_reg_field dma_tile_c_lim;
    uvm_reg_field dma_tile_k_lim;

    function new(string name="sauria_dma_controller_cfg_reg_1");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction

    function void build_fields();
        dma_tile_c_lim = uvm_reg_field::type_id::create("sauria_dma_tile_c_lim");
        dma_tile_k_lim = uvm_reg_field::type_id::create("sauria_dma_tile_k_lim");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");
        super.configure(blk_parent, regfile_parent, hdl_path);

        dma_tile_c_lim.configure(.parent(this), .size(DMA_TILE_C_LIM_SIZE), .lsb_pos(DMA_TILE_C_LIM_LSB), .access(REG_CFG_ACCESS), .volatile(REG_CFG_VOLATILE_VAL), .reset(REG_CFG_RESET_VAL), .has_reset(REG_CFG_HAS_RESET), .is_rand(REG_CFG_IS_RAND), .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
        dma_tile_k_lim.configure(.parent(this), .size(DMA_TILE_K_LIM_SIZE), .lsb_pos(DMA_TILE_K_LIM_LSB), .access(REG_CFG_ACCESS), .volatile(REG_CFG_VOLATILE_VAL), .reset(REG_CFG_RESET_VAL), .has_reset(REG_CFG_HAS_RESET), .is_rand(REG_CFG_IS_RAND), .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
    endfunction

endclass
