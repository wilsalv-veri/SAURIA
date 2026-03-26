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
    virtual sauria_psums_mgr_shift_reg_ifc sauria_psums_mgr_shift_reg_if;

    localparam RD_LAT    = 3;
    localparam SHIFT_LAT = 2;
    localparam PSUM_ELEM_LEN = $bits(sauria_psums_elem_data_t);

    sramc_data_t              shift_reg_data[$];     
    sramc_data_t              shift_reg_data_entry;      
     
    scan_chain_data_t         shift_reg_entry;
    scan_chain_data_t         bus_val;

    sauria_psums_mgr_seq_item psums_mgr_info;
    int                       curr_read_context_num,  next_read_context_num;
    int                       curr_write_context_num, next_write_context_num;

    sramc_addr_t              sramc_read_addr, sramc_write_addr;
    int                       shift_count;

    bit                       new_context;
    bit                       pending_shift_reg_check;
    bit                       pending_scan_chain_bus_check;
    bit                       pending_sramc_bus_check;
    bit                       shift_sram_data;

    int                       read_tile_idx;
    int                       write_tile_idx;
    int                       num_tiles;
    int                       sramc_acceses_per_tile;
    int                       rd_done_count;
    int                       addr_zero_count;
    bit                       shift;

    arr_row_data_t             psums_inactive_cols;
    arr_col_data_t             psums_rows_active;

    function new(string name="sauria_psums_mgr_scbd", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_psums_mgr_sramc_read_info     = new("RECEIVE_SAURIA_PSUMS_MGR_SRAMC_READ_INFO", this);
        receive_psums_mgr_sramc_write_info    = new("RECEIVE_SAURIA_PSUMS_MGR_SRAMC_WRITE_INFO", this);
        receive_psums_mgr_preload_values_info = new("RECEIVE_SAURIA_PSUMS_MGR_PRELOAD_VALUES_INFO", this);
        receive_psums_mgr_shift_reg_info      = new("RECEIVE_SAURIA_PSUMS_MGR_SHIFT_REG_INFO", this);

        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        if(!uvm_config_db #(virtual sauria_psums_mgr_shift_reg_ifc)::get(this, "", "sauria_psums_mgr_shift_reg_if" , sauria_psums_mgr_shift_reg_if))
            `sauria_error(message_id, "Failed to get access to sauria_psums_mgr_shift_reg_if")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.shared);
        sramc_acceses_per_tile =  computation_params.psums_CK / computation_params.psums_ck_step;
        num_tiles              =  (computation_params.tile_psums_CY / computation_params.tile_psums_cy_step) 
                                * (computation_params.tile_psums_CK / computation_params.tile_psums_ck_step);

        wait(computation_params.ifmaps_cfg_shared);
        psums_rows_active = computation_params.ifmaps_rows_active;
        
        wait(computation_params.psums_mgr_cfg_shared);
        psums_inactive_cols =  computation_params.psums_inactive_cols;
    endtask

    function write_psums_mgr_sramc_read_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        this.psums_mgr_info = psums_mgr_info;
        next_read_context_num =  this.psums_mgr_info.context_num;
        if(!rd_done_count) check_next_read_address();
        if(!new_context)   update_exp_read_addr();
        
        if (rd_done_count <= RD_LAT)begin
            pending_shift_reg_check      = 1'b1;
            pending_scan_chain_bus_check = 1'b1;
            shift_sram_data              = 1'b1;

            if(shift) begin
                if(shift_reg_data.size() == sauria_pkg::X) shift_reg_entry = shift_reg_data.pop_back();
                shift_reg_data.push_front(psums_mgr_info.sramc_rdata);
            end
            else set_shift();
        end 
            
        curr_read_context_num =  next_read_context_num;
        
    endfunction

    function write_psums_mgr_preload_values_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        this.psums_mgr_info = psums_mgr_info;
        if ((shift_count < sauria_pkg::X) && (pending_scan_chain_bus_check)) begin
            if (shift_reg_data.size() > 0) begin
                check_preload_values();
            
                if(shift_count == (sauria_pkg::X - 1)) begin
                    pending_scan_chain_bus_check = 1'b0;
                    shift_count = 0;
                end
                else shift_count++;
            end 
            else `sauria_error(message_id, $sformatf("Scan Chain Active When Empty Shift Reg Shift_Count: %0d", shift_count))
        end
        shift_reg_data_entry = get_reversed_scan_chain_bus(psums_mgr_info.i_c_arr);
        shift_reg_data.push_front(shift_reg_data_entry); 
        pending_shift_reg_check = 1'b1;
        shift_sram_data         = 1'b0;
        
    endfunction

    function write_psums_mgr_shift_reg_info(sauria_psums_mgr_seq_item psums_mgr_shift_reg_info);
        
        if (pending_shift_reg_check && psums_mgr_shift_reg_info.shift_done)begin
            check_shift_reg_data();
            pending_shift_reg_check = 1'b0;
            shift = 0;
        end
    endfunction

    function write_psums_mgr_sramc_write_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        this.psums_mgr_info = psums_mgr_info;
        next_write_context_num = this.psums_mgr_info.context_num;
        check_next_write_address();
        update_exp_write_addr();
        if (shift_reg_data.size() > 0)
            check_write_data();
        else `sauria_error(message_id, "Empty Shift Register Fifo At Time of SRAMC Write")
        curr_write_context_num = next_write_context_num;
    endfunction

    virtual function void check_next_read_address();
        if(curr_read_context_num != next_read_context_num) begin
            sramc_read_addr = sramc_addr_t'(0);
            new_context = 1'b1;
            return;
        end
        else if (new_context) 
            new_context = 1'b0;
        else if(sramc_read_addr != psums_mgr_info.sramc_addr)
            `sauria_error(message_id, $sformatf("Incorrect Read SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h  RD_DONE_Count: %0d", sramc_read_addr, psums_mgr_info.sramc_addr, rd_done_count))
    endfunction

    virtual function void check_next_write_address();
        if (sramc_write_addr != psums_mgr_info.sramc_addr)
            `sauria_error(message_id, $sformatf("Incorrect Write SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", sramc_write_addr, psums_mgr_info.sramc_addr)) 
    endfunction

    virtual function void check_write_data();
        shift_reg_entry = shift_reg_data.pop_back();
        if (shift_reg_entry != psums_mgr_info.sramc_wdata)
            `sauria_error(message_id, $sformatf("Shift Register and SRAMC Write Bus Data Value Mismatch Exp: 0x%0h Act: 0x%0h", shift_reg_entry, psums_mgr_info.sramc_wdata))
    endfunction

    virtual function void check_shift_reg_data();
        for(int col=0; col < sauria_pkg::X; col++ )begin 
            
            mask_shift_reg_cols_rows(col);
            if(shift_reg_data[col] != sauria_psums_mgr_shift_reg_if.psums_shift_reg[col+1]) begin
                `sauria_error(message_id, $sformatf("Unexpected Data Entry in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                col + 1, shift_reg_data[col], sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
            end
            else   `sauria_info(message_id, $sformatf("Data Entry Match in Partial Sum Shift Register Col: %0d Exp: 0x%0h Act: 0x%0h",
                col + 1, shift_reg_data[col], sauria_psums_mgr_shift_reg_if.psums_shift_reg[col + 1]))
            
        end
    endfunction
    
    virtual function void check_preload_values();
        mask_inactive_preload_cols_rows(shift_count);
        shift_reg_entry = scan_chain_data_t'(shift_reg_data.pop_back());

        
        for(int row=0; row < sauria_pkg::Y; row++)begin
            if (shift_reg_entry[sauria_pkg::Y - 1 - row] != psums_mgr_info.o_c_arr[row])
            `sauria_error(message_id, $sformatf("Shift Register and Scan Chain Bus Value Mismatch Row: %0d Exp: 0x%0h Act: 0x%0h", row, shift_reg_entry[sauria_pkg::Y - 1 - row], psums_mgr_info.o_c_arr[row]))
        end
    endfunction
    
    virtual function void update_exp_read_addr();
        if( (((sramc_read_addr % sramc_acceses_per_tile) == (sramc_acceses_per_tile - 1)) || (rd_done_count > 0)) && (rd_done_count <= RD_LAT) )begin      
            rd_done_count++;
        end
        else if (rd_done_count == (RD_LAT + 1)) begin
            sramc_read_addr = 0;
            rd_done_count   = 0;
            read_tile_idx   = (read_tile_idx == num_tiles - 1) ? 0 : read_tile_idx + 1;
        end
        else begin
            sramc_read_addr++;
        end
        
        sramc_read_addr = (rd_done_count > 1) ? 0 : (read_tile_idx*sramc_acceses_per_tile) + (sramc_read_addr % sramc_acceses_per_tile);
    endfunction

    virtual function void update_exp_write_addr();
        sramc_write_addr++;
        sramc_write_addr = (write_tile_idx * sramc_acceses_per_tile) + (sramc_write_addr % sramc_acceses_per_tile);

        if((sramc_write_addr % sramc_acceses_per_tile) == sramc_acceses_per_tile - 1) 
            write_tile_idx   = (write_tile_idx == num_tiles - 1) ? 0 : write_tile_idx + 1;
        
    endfunction

    virtual function void set_shift();
        if (addr_zero_count == 0)begin
            addr_zero_count++;
        end
        else if (addr_zero_count == RD_LAT) begin
            addr_zero_count = 0;
            shift = 1'b1;
        end
        else if ((addr_zero_count > 0) && (addr_zero_count < RD_LAT)) begin
            addr_zero_count++;
        end   
    endfunction

    virtual function scan_chain_data_t get_reversed_scan_chain_bus(scan_chain_data_t bus_entry);
        scan_chain_data_t reversed_bus;
        for(int row=0; row < sauria_pkg::Y; row++)begin
            reversed_bus[row] = bus_entry[sauria_pkg::Y - 1 - row];
        end
        return reversed_bus;
    endfunction

    virtual function void mask_inactive_preload_cols_rows(int col);
        int data_col     = shift_reg_data.size() - 1;
        bit inactive_col = col > (sauria_pkg::X - psums_inactive_cols - 1);
        mask_inactive_cols_rows_data(data_col, inactive_col, 1'b1);
    endfunction

    virtual function void mask_shift_reg_cols_rows(int col);
        bit inactive_col = (pending_scan_chain_bus_check ? (col < psums_inactive_cols) : 1'b0);
        mask_inactive_cols_rows_data(col, inactive_col, 1'b0);
    endfunction

    virtual function void mask_inactive_cols_rows_data(int col, bit inactive_col, bit row_rev);
        int elem_start_offset;
        int data_row;
 
        `sauria_info(message_id, $sformatf("Masking Cols_Rows Data Col: %0d Inactive_Col : %0d Row_Rev: %0d",
                                col, inactive_col, row_rev)) 

        for(int row=0; row < sauria_pkg::Y; row++)begin

            data_row = row_rev ? sauria_pkg::Y - 1 - row : row;
            elem_start_offset = data_row * PSUM_ELEM_LEN;

            if (!psums_rows_active[data_row] || inactive_col) begin
                `sauria_info(message_id, $sformatf("De-activating Partial Sum Col: %0d Row: %0d", col, row))
                shift_reg_data[col][elem_start_offset +: PSUM_ELEM_LEN] = sauria_psums_elem_data_t'(0);
            end
        end
        
    endfunction


endclass