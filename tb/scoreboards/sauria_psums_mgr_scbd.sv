class sauria_psums_mgr_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_psums_mgr_scbd)

    `uvm_analysis_imp_decl (_psums_mgr_sramc_read_info)
    uvm_analysis_imp_psums_mgr_sramc_read_info #(sauria_psums_mgr_seq_item, sauria_psums_mgr_scbd) receive_psums_mgr_sramc_read_info;

    `uvm_analysis_imp_decl (_psums_mgr_sramc_write_info)
    uvm_analysis_imp_psums_mgr_sramc_write_info #(sauria_psums_mgr_seq_item, sauria_psums_mgr_scbd) receive_psums_mgr_sramc_write_info;

    `uvm_analysis_imp_decl (_psums_mgr_preload_values_info)
    uvm_analysis_imp_psums_mgr_preload_values_info #(sauria_psums_mgr_seq_item, sauria_psums_mgr_scbd) receive_psums_mgr_preload_values_info;

    `uvm_analysis_imp_decl (_psums_mgr_shift_reg_info)
    uvm_analysis_imp_psums_mgr_shift_reg_info #(sauria_psums_mgr_seq_item, sauria_psums_mgr_scbd) receive_psums_mgr_shift_reg_info;

    string message_id = "SAURIA_PSUMS_MGR_SCBD";

    sauria_computation_params computation_params;
    sauria_psums_mgr_model    psums_mgr_model;
    
    scan_chain_data_t         shift_reg_entry;
    
    virtual sauria_psums_mgr_shift_reg_ifc sauria_psums_mgr_shift_reg_if;

    function new(string name="sauria_psums_mgr_scbd", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_psums_mgr_sramc_read_info     = new("RECEIVE_SAURIA_PSUMS_MGR_SRAMC_READ_INFO", this);
        receive_psums_mgr_sramc_write_info    = new("RECEIVE_SAURIA_PSUMS_MGR_SRAMC_WRITE_INFO", this);
        receive_psums_mgr_preload_values_info = new("RECEIVE_SAURIA_PSUMS_MGR_PRELOAD_VALUES_INFO", this);
        receive_psums_mgr_shift_reg_info      = new("RECEIVE_SAURIA_PSUMS_MGR_SHIFT_REG_INFO", this);

        psums_mgr_model                       = sauria_psums_mgr_model::type_id::create("sauria_psums_mgr_model");

        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        if(!uvm_config_db #(virtual sauria_psums_mgr_shift_reg_ifc)::get(this, "", "sauria_psums_mgr_shift_reg_if" , sauria_psums_mgr_shift_reg_if))
            `sauria_error(message_id, "Failed to get access to sauria_psums_mgr_shift_reg_if")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
       
        wait(computation_params.main_controller_cfg_shared);
        
        psums_mgr_model.set_reps(computation_params.act_reps, computation_params.wei_reps);
       
        wait(computation_params.ifmaps_cfg_shared);
        wait(computation_params.psums_mgr_cfg_shared);
        
        psums_mgr_model.configure(computation_params.core_psums_params, 
                                 arr_col_data_t'(computation_params.ifmaps_rows_active),
                                 arr_row_data_t'(computation_params.psums_inactive_cols) );

        endtask

    function write_psums_mgr_sramc_read_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        `sauria_info(message_id, $sformatf("Received SRAMC Read Info: Context Num: %0d, SRAMC Addr: 0x%0h, SRAMC RData: 0x%0h", 
                                psums_mgr_info.context_num, psums_mgr_info.sramc_addr, psums_mgr_info.sramc_rdata))

        if (psums_mgr_model.is_valid_shift())
            check_next_read_address(psums_mgr_info.sramc_addr);

        psums_mgr_model.add_psums_sram_rd_access(psums_mgr_info.sramc_rdata);
                
    endfunction

    function write_psums_mgr_sramc_write_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        check_next_write_address(psums_mgr_info.sramc_addr);
        psums_mgr_model.add_psums_sram_wr_access();
       
        if (!psums_mgr_model.is_shift_reg_data_empty())
            check_write_data(psums_mgr_info.sramc_wdata);
        else `sauria_error(message_id, "Empty Shift Register Fifo At Time of SRAMC Write")
    endfunction

    function write_psums_mgr_preload_values_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        if (psums_mgr_model.is_valid_preload_data())
            check_preload_data(psums_mgr_info.o_c_arr);

        psums_mgr_model.add_preload_values(psums_mgr_info.i_c_arr);

    endfunction

    function write_psums_mgr_shift_reg_info(sauria_psums_mgr_seq_item psums_mgr_shift_reg_info);
        
        if (psums_mgr_shift_reg_info.shift_done && psums_mgr_model.is_valid_psums_shift_reg_data())
            check_psums_shift_reg_data();
        
    endfunction

    virtual function void check_next_read_address(sramc_addr_t sramc_addr);
        if(psums_mgr_model.get_next_rd_sramc_addr() != sramc_addr) 
            `sauria_error(message_id, $sformatf("Incorrect Read SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", psums_mgr_model.get_next_rd_sramc_addr(), sramc_addr ))
    endfunction

    virtual function void check_next_write_address(sramc_addr_t sramc_addr);
        if (psums_mgr_model.get_next_wr_sramc_addr() != sramc_addr)
            `sauria_error(message_id, $sformatf("Incorrect Write SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", psums_mgr_model.get_next_wr_sramc_addr(), sramc_addr)) 
    endfunction

    virtual function void check_write_data(sramc_data_t sramc_wdata);
        shift_reg_entry = psums_mgr_model.get_shift_reg_data_entry();
        if (shift_reg_entry != sramc_wdata)
            `sauria_error(message_id, $sformatf("Shift Register and SRAMC Write Bus Data Value Mismatch Exp: 0x%0h Act: 0x%0h", shift_reg_entry, sramc_wdata))
    endfunction

    virtual function void check_psums_shift_reg_data();
        for(int col=0; col < sauria_pkg::X; col++ )begin 
            shift_reg_entry = psums_mgr_model.get_masked_shift_reg_data_entry(col);

            if(shift_reg_entry != sauria_psums_mgr_shift_reg_if.psums_shift_reg[col+1]) begin
                `sauria_error(message_id, $sformatf("Unexpected Data Entry in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                col + 1, shift_reg_entry, sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
            end
            else   `sauria_info(message_id, $sformatf("Data Entry Match in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                col + 1, shift_reg_entry, sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
            
        end
    endfunction

    virtual function void check_preload_data(scan_chain_data_t o_c_arr);
        shift_reg_entry = psums_mgr_model.get_masked_preload_data();

        for(int row=0; row < sauria_pkg::Y; row++)begin
            if (shift_reg_entry[sauria_pkg::Y - 1 - row] != o_c_arr[row])
            `sauria_error(message_id, $sformatf("Shift Register and Output Scan Chain Bus Value Mismatch Row: %0d Exp: 0x%0h Act: 0x%0h", row, shift_reg_entry[sauria_pkg::Y - 1 - row], o_c_arr[row]))
        end
    endfunction
    
endclass