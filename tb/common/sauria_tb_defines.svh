

`define sauria_info(message_id, message)    `uvm_info(message_id, message, UVM_NONE)
`define sauria_warning(message_id, message) `uvm_warning(message_id, message)
`define sauria_error(message_id, message)   `uvm_error(message_id, message)
`define sauria_fatal(message_id, message)   `uvm_fatal(message_id, message)

`define sauria_sva_info(message)    $info(message)
`define sauria_sva_error(message)   $error(message)
