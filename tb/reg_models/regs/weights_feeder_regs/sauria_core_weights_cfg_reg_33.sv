class sauria_core_weights_cfg_reg_33 extends uvm_reg;

    `uvm_object_utils(sauria_core_weights_cfg_reg_33)

    uvm_reg_field weights_w_lim;
    uvm_reg_field weights_w_step;
    uvm_reg_field weights_k_lim_lower; //Only for FP

    function new(string name="sauria_core_weights_cfg_reg_33");
        super.new(name, SAURIA_REG_SIZE, REG_COVERAGE);
    endfunction 

    function void build_fields();
        weights_w_lim       = uvm_reg_field::type_id::create("sauria_core_weights_w_lim");
        weights_w_step      = uvm_reg_field::type_id::create("sauria_core_weights_w_step");
        weights_k_lim_lower = uvm_reg_field::type_id::create("sauria_core_weights_k_lim_lower");
    endfunction

    function void configure(uvm_reg_block blk_parent, uvm_reg_file regfile_parent=null, string hdl_path="");

        super.configure(blk_parent, regfile_parent, hdl_path);
    
        weights_w_lim.configure(.parent(this),
                                    .size(WEI_TILE_DIM_SIZE),
                                    .lsb_pos(WEI_W_LIM_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        weights_w_step.configure(.parent(this),
                                    .size(WEI_TILE_DIM_SIZE),
                                    .lsb_pos(WEI_W_STEP_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));

        if (FP_ARITHMETIC)begin 
            weights_k_lim_lower.configure(.parent(this),
                                    .size(WEI_K_LIM_LOWER_SIZE),
                                    .lsb_pos(WEI_K_LIM_LOWER_LSB),
                                    .access(REG_CFG_ACCESS),
                                    .volatile(REG_CFG_VOLATILE_VAL),
                                    .reset(REG_CFG_RESET_VAL),
                                    .has_reset(REG_CFG_HAS_RESET),
                                    .is_rand(REG_CFG_IS_RAND),
                                    .individually_accessible(REG_CFG_INDIVIDUALLY_ACCESSIBLE));
        end
        
    endfunction

endclass