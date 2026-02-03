`ifndef SAURIA_GOLDEN_MODEL_PKG
`define SAURIA_GOLDEN_MODEL_PKG

package sauria_golden_model_pkg;

    import uvm_pkg::*;
    import sauria_common_pkg::*;

    `include "sauria_base_model.sv"
    `include "sauria_dma_mem_req_shape_model.sv"
    `include "sauria_tensor_ptr_model.sv"

endpackage

`endif //SAURIA_GOLDEN_MODEL_PKG