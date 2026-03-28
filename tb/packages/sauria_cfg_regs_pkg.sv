`ifndef SAURIA_CFG_REGS_PKG
`define SAURIA_CFG_REGS_PKG

package sauria_cfg_regs_pkg;

    import uvm_pkg::*;
    import sauria_pkg::*;
    import sauria_common_pkg::*;
    
   
    parameter REG_FLAG_SIZE                   = 1;
    parameter REG_COVERAGE                    = UVM_NO_COVERAGE;
    parameter REG_CFG_VOLATILE_VAL            = 0;
    parameter string REG_CFG_ACCESS           = "RW";
    parameter REG_CFG_RESET_VAL               = 'h0;
    parameter REG_CFG_HAS_RESET               = 0;
    parameter REG_CFG_IS_RAND                 = 0;
    parameter REG_CFG_INDIVIDUALLY_ACCESSIBLE = 0;

    parameter CORE_CFG_REGS_OFFSET = 'h10;
    
    function uvm_reg_addr_t get_cfg_addr_from_idx(int df_ctrl_cfg_cr_idx);
        return uvm_reg_addr_t'(CORE_CFG_REGS_OFFSET + df_ctrl_cfg_cr_idx*SAURIA_REG_SIZE_BYTES);
    endfunction
  
    `include "sauria_cfg_regs_params.sv"

    `include "../reg_models/regs/df_controller_regs/sauria_df_controller_cfg_reg_18.sv"
    `include "../reg_models/regs/df_controller_regs/sauria_df_controller_cfg_reg_19.sv"
    `include "../reg_models/regs/df_controller_regs/sauria_df_controller_cfg_reg_20.sv"
    `include "../reg_models/regs/df_controller_regs/sauria_df_controller_cfg_reg_21.sv"

    `include "sauria_core_main_controller_cfg_reg_22.sv"
    `include "sauria_core_main_controller_cfg_reg_23.sv"

    `include "sauria_core_ifmaps_cfg_reg_24.sv"
    `include "sauria_core_ifmaps_cfg_reg_25.sv"
    `include "sauria_core_ifmaps_cfg_reg_26.sv"
    `include "sauria_core_ifmaps_cfg_reg_27.sv"
    `include "sauria_core_ifmaps_cfg_reg_28.sv"
    `include "sauria_core_ifmaps_cfg_reg_29.sv"
    `include "sauria_core_ifmaps_cfg_reg_30.sv"
    `include "sauria_core_ifmaps_cfg_reg_31.sv"
    `include "sauria_core_ifmaps_cfg_reg_32.sv"

    `include "sauria_core_weights_cfg_reg_33.sv"
    `include "sauria_core_weights_cfg_reg_34.sv"
    `include "sauria_core_weights_cfg_reg_35.sv"
    `include "sauria_core_weights_cfg_reg_36.sv"

    `include "sauria_core_psums_cfg_reg_37.sv"
    `include "sauria_core_psums_cfg_reg_38.sv"
    `include "sauria_core_psums_cfg_reg_39.sv"
    `include "sauria_core_psums_cfg_reg_40.sv"
    `include "sauria_core_psums_cfg_reg_41.sv"

    `include "../reg_models/reg_blocks/sauria_df_controller_reg_block.sv"
    `include "sauria_core_main_controller_reg_block.sv"
    `include "sauria_core_ifmaps_reg_block.sv"
    `include "sauria_core_weights_reg_block.sv"
    `include "sauria_core_psums_reg_block.sv"

endpackage

`endif