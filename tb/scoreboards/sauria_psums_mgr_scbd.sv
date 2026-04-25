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

        psums_mgr_model.set_computation_params(computation_params);
        
        if(!uvm_config_db #(virtual sauria_psums_mgr_shift_reg_ifc)::get(this, "", "sauria_psums_mgr_shift_reg_if" , sauria_psums_mgr_shift_reg_if))
            `sauria_error(message_id, "Failed to get access to sauria_psums_mgr_shift_reg_if")
    endfunction

    function write_psums_mgr_sramc_read_info(sauria_psums_mgr_seq_item psums_mgr_info);
        psums_mgr_sramc_read_result_t read_result;
        
        `sauria_info(message_id, $sformatf("Received SRAMC Read Info: Context Num: %0d, SRAMC Addr: 0x%0h, SRAMC RData: 0x%0h", 
                                psums_mgr_info.context_num, psums_mgr_info.sramc_addr, psums_mgr_info.sramc_rdata))

        read_result = psums_mgr_model.observe_sramc_read(psums_mgr_info.sramc_addr,
                                                         psums_mgr_info.sramc_rdata);

        if (read_result.addr_check_valid && read_result.addr_mismatch)
            `sauria_error(message_id, $sformatf("Incorrect Read SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", read_result.exp_addr, psums_mgr_info.sramc_addr ))
                
    endfunction

    function write_psums_mgr_sramc_write_info(sauria_psums_mgr_seq_item psums_mgr_info);
        psums_mgr_sramc_write_result_t write_result;
        
        write_result = psums_mgr_model.observe_sramc_write(psums_mgr_info.sramc_addr,
                                                           psums_mgr_info.sramc_wdata);

        if (write_result.addr_mismatch)
            `sauria_error(message_id, $sformatf("Incorrect Write SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", write_result.exp_addr, psums_mgr_info.sramc_addr))
       
        if (write_result.shift_reg_data_empty)
            `sauria_error(message_id, "Empty Shift Register Fifo At Time of SRAMC Write")
        else if (write_result.exp_wdata != psums_mgr_info.sramc_wdata)
            `sauria_error(message_id, $sformatf("Shift Register and SRAMC Write Bus Data Value Mismatch Exp: 0x%0h Act: 0x%0h", write_result.exp_wdata, psums_mgr_info.sramc_wdata))
    endfunction

    function write_psums_mgr_preload_values_info(sauria_psums_mgr_seq_item psums_mgr_info);
        psums_mgr_preload_result_t preload_result;
        
        preload_result = psums_mgr_model.observe_preload_values(psums_mgr_info.i_c_arr,
                                                                psums_mgr_info.o_c_arr);

        if (preload_result.valid_preload_check) begin
            for(int row=0; row < sauria_pkg::Y; row++)begin
                if (preload_result.exp_preload_data[sauria_pkg::Y - 1 - row] != psums_mgr_info.o_c_arr[row])
                    `sauria_error(message_id, $sformatf("Shift Register and Output Scan Chain Bus Value Mismatch Row: %0d Exp: 0x%0h Act: 0x%0h", row, preload_result.exp_preload_data[sauria_pkg::Y - 1 - row], psums_mgr_info.o_c_arr[row]))
            end
        end

    endfunction

    function write_psums_mgr_shift_reg_info(sauria_psums_mgr_seq_item psums_mgr_shift_reg_info);
        psums_mgr_shift_reg_result_t shift_reg_result;
        
        shift_reg_result = psums_mgr_model.observe_shift_reg(psums_mgr_shift_reg_info.shift_done);

        if (shift_reg_result.valid_snapshot) begin
            for(int col=0; col < sauria_pkg::X; col++ )begin 
                if(shift_reg_result.exp_shift_reg[col] != sauria_psums_mgr_shift_reg_if.psums_shift_reg[col+1]) begin
                    `sauria_error(message_id, $sformatf("Unexpected Data Entry in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                    col + 1, shift_reg_result.exp_shift_reg[col], sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
                end
                else   `sauria_info(message_id, $sformatf("Data Entry Match in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                    col + 1, shift_reg_result.exp_shift_reg[col], sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
            end
        end
        
    endfunction
    
endclass