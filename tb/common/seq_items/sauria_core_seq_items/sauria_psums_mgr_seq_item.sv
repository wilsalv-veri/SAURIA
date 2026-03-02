class sauria_psums_mgr_seq_item extends uvm_sequence_item;

    sramc_data_t          sramc_rdata;      // Read data bus from SRAMC
    sramc_addr_t          sramc_addr;       // Address towards SRAMC
    bit                   sramc_wren;       // Write Enable for SRAMC
    bit                   sramc_rden;       // Read Enable for SRAMC
    sramc_data_mask_t     sramc_wmask;      // Write Mask for SRAMC

    bit                   cscan_en;         // Output Scan-Chain Enable
    sramc_data_t          sramc_wdata;      // Write data bus towards SRAMC
    scan_chain_data_t     i_c_arr;          // MAC preload values (scan chain) input
    scan_chain_data_t     o_c_arr;          // MAC preload values (scan chain) output
    
    bit                   shift_done;
    int                   context_num;      

    `uvm_object_utils_begin(sauria_psums_mgr_seq_item)
        `uvm_field_int(sramc_addr,  UVM_ALL_ON)
        `uvm_field_int(sramc_wren,  UVM_ALL_ON)
        `uvm_field_int(sramc_rden,  UVM_ALL_ON)
        `uvm_field_int(sramc_wmask, UVM_ALL_ON)
        `uvm_field_int(cscan_en,    UVM_ALL_ON)
        `uvm_field_int(sramc_wdata, UVM_ALL_ON)
        `uvm_field_int(i_c_arr,     UVM_ALL_ON)
        `uvm_field_int(o_c_arr,     UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name="sauria_psums_mgr_seq_item");
        super.new(name);
    endfunction

endclass