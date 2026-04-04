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
    psums_params_t   psums_params;

    virtual sauria_psums_mgr_shift_reg_ifc sauria_psums_mgr_shift_reg_if;

    localparam RD_LAT    = 2;
    localparam SHIFT_LAT = 1;
    localparam PSUM_ELEM_LEN = $bits(sauria_psums_elem_data_t);

    sramc_data_t              shift_reg_data[$];     
    sramc_data_t              shift_reg_data_entry;      
     
    scan_chain_data_t         shift_reg_entry;
    scan_chain_data_t         bus_val;

    sauria_psums_mgr_seq_item psums_mgr_info;
    int                       curr_read_context_num,  next_read_context_num;
    int                       curr_write_context_num, next_write_context_num;

    sramc_addr_t              exp_next_rd_sramc_addr, exp_next_wr_sramc_addr;
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

    sauria_axi4_lite_data_t    rd_shift_k_idx, rd_k_idx,rd_x_idx;
    sauria_axi4_lite_data_t    wr_shift_k_idx, wr_k_idx,wr_x_idx;
    sauria_axi4_lite_data_t       shift_k_idx,    k_idx,   x_idx;
    
    sauria_axi4_lite_data_t    shift_k_lim;
    sauria_axi4_lite_data_t    act_reps, wei_reps;
    
    sauria_axi4_lite_data_t    rd_act_rep_idx, rd_wei_rep_idx;
    sauria_axi4_lite_data_t    wr_act_rep_idx, wr_wei_rep_idx;
    sauria_axi4_lite_data_t       act_rep_idx, wei_rep_idx;

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
       
        wait(computation_params.main_controller_cfg_shared);
        act_reps         = computation_params.act_reps;
        wei_reps         = computation_params.wei_reps;
       
        wait(computation_params.ifmaps_cfg_shared);
        psums_rows_active = arr_col_data_t'(computation_params.ifmaps_rows_active);
        
        wait(computation_params.psums_mgr_cfg_shared);
        psums_params = computation_params.core_psums_params;

        sramc_acceses_per_tile = sauria_pkg::X; 
        shift_k_lim            = psums_params.tile_params.psums_ck_step * sramc_acceses_per_tile;
        num_tiles              = (psums_params.tile_params.psums_CX / SRAMA_N) * (psums_params.tile_params.psums_K  / SRAMB_N);
    
        psums_inactive_cols = arr_row_data_t'(computation_params.psums_inactive_cols);
         
        `sauria_info(message_id, $sformatf("SRAMC_Acceses_Per_Tile: %0d Num_Tiles: %0d", sramc_acceses_per_tile, num_tiles))

    endtask

    function write_psums_mgr_sramc_read_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        `sauria_info(message_id, $sformatf("Received SRAMC Read Info: Context Num: %0d, SRAMC Addr: 0x%0h, SRAMC RData: 0x%0h", 
                                psums_mgr_info.context_num, psums_mgr_info.sramc_addr, psums_mgr_info.sramc_rdata))

        this.psums_mgr_info = psums_mgr_info;
        next_read_context_num =  this.psums_mgr_info.context_num;
        
        if(shift) begin
                
            pending_shift_reg_check      = 1'b1;
            pending_scan_chain_bus_check = 1'b1;
            shift_sram_data              = 1'b1;
                
            if (rd_done_count == RD_LAT) begin
                shift_count   = -1; //Will become 0 
                rd_done_count =  0;
            end
            else if (shift_count < sauria_pkg::X) begin
                `sauria_info(message_id, "Pushing SRAMC Data")
                
                check_next_read_address();
                update_exp_sramc_addr(RD_TXN);

                if(shift_reg_data.size() == sauria_pkg::X) shift_reg_entry = shift_reg_data.pop_back();
                shift_reg_data.push_front(psums_mgr_info.sramc_rdata);
                    
            end
            else 
                rd_done_count++;

            shift_count++;
            
        end
        else set_shift();
           
        curr_read_context_num =  next_read_context_num;
        
    endfunction

    function write_psums_mgr_preload_values_info(sauria_psums_mgr_seq_item psums_mgr_info);
        
        this.psums_mgr_info = psums_mgr_info;
        if ((shift_count <= sauria_pkg::X) && (pending_scan_chain_bus_check)) begin
        
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
        
        //FIXME: wilsalv :Re-enable
        check_next_write_address();
        update_exp_sramc_addr(WR_TXN);

        if (shift_reg_data.size() > 0)
            check_write_data();
        else `sauria_error(message_id, "Empty Shift Register Fifo At Time of SRAMC Write")
        curr_write_context_num = next_write_context_num;
    endfunction

    virtual function void check_next_read_address();
        if(exp_next_rd_sramc_addr != psums_mgr_info.sramc_addr) 
            `sauria_error(message_id, $sformatf("Incorrect Read SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h  RD_DONE_Count: %0d", exp_next_rd_sramc_addr, psums_mgr_info.sramc_addr, rd_done_count))
    endfunction

    virtual function void check_next_write_address();
        if (exp_next_wr_sramc_addr != psums_mgr_info.sramc_addr)
            `sauria_error(message_id, $sformatf("Incorrect Write SRAMC Address Accessed From Partial Sums Manager Exp: %0h Act: %0h", exp_next_wr_sramc_addr, psums_mgr_info.sramc_addr)) 
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
            `sauria_error(message_id, $sformatf("Shift Register and Output Scan Chain Bus Value Mismatch Row: %0d Exp: 0x%0h Act: 0x%0h", row, shift_reg_entry[sauria_pkg::Y - 1 - row], psums_mgr_info.o_c_arr[row]))
        end
    endfunction
    
    virtual function void update_exp_sramc_addr(sauria_axi_txn_type_t operation);
        select_operation_counters(operation);
        update_counters();
        set_counter_based_exp_addr(operation);
        update_operation_counters(operation);
    endfunction

    virtual function void select_operation_counters(sauria_axi_txn_type_t operation);
        act_rep_idx = (operation == RD_TXN) ? rd_act_rep_idx : wr_act_rep_idx;
        shift_k_idx = (operation == RD_TXN) ? rd_shift_k_idx : wr_shift_k_idx;
        k_idx       = (operation == RD_TXN) ? rd_k_idx       : wr_k_idx;
        x_idx       = (operation == RD_TXN) ? rd_x_idx       : wr_x_idx;
    endfunction

    virtual function void update_operation_counters(sauria_axi_txn_type_t operation);
        case(operation)
            RD_TXN: begin
                rd_act_rep_idx  = act_rep_idx;
                rd_shift_k_idx  = shift_k_idx;
                rd_k_idx        = k_idx; 
                rd_x_idx        = x_idx; 
            end
            WR_TXN: begin
                wr_act_rep_idx  = act_rep_idx; 
                wr_shift_k_idx  = shift_k_idx; 
                wr_k_idx        = k_idx;
                wr_x_idx        = x_idx;
            end
        endcase
    endfunction

    virtual function void set_shift();
        if (addr_zero_count == 0)begin
            addr_zero_count++;
        end
        else if (addr_zero_count == RD_LAT - 1) begin
            addr_zero_count = 0;
            shift_count = 0;
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
 
        for(int row=0; row < sauria_pkg::Y; row++)begin

            data_row = row_rev ? sauria_pkg::Y - 1 - row : row;
            elem_start_offset = data_row * PSUM_ELEM_LEN;

            if (!psums_rows_active[data_row] || inactive_col) begin
                `sauria_info(message_id, $sformatf("De-activating Partial Sum Col: %0d Row: %0d", col, row))
                shift_reg_data[col][elem_start_offset +: PSUM_ELEM_LEN] = sauria_psums_elem_data_t'(0);
            end
        end
        
    endfunction

    virtual function void set_counter_based_exp_addr(sauria_axi_txn_type_t operation);
        case(operation)
            RD_TXN: exp_next_rd_sramc_addr = (shift_k_idx + k_idx + x_idx) / SRAMC_N; 
            WR_TXN: exp_next_wr_sramc_addr = (shift_k_idx + k_idx + x_idx) / SRAMC_N;
        endcase
    endfunction

    virtual function void update_counters();

        if ((shift_k_idx + psums_params.tile_params.psums_ck_step) 
            < shift_k_lim)begin
            shift_k_idx += psums_params.tile_params.psums_ck_step;
        end
        else if ((x_idx + psums_params.tile_params.psums_cx_step) 
            < psums_params.tile_params.psums_CX)begin
            shift_k_idx = 0;
            x_idx      += psums_params.tile_params.psums_cx_step;
        end
        else if ((shift_k_idx + k_idx + psums_params.tile_params.psums_ck_step)
            < psums_params.tile_params.psums_CK) begin
            act_rep_idx++;
            shift_k_idx = 0;
            x_idx       = 0;
            k_idx       = act_rep_idx * shift_k_lim;
        end
        else begin
            act_rep_idx = 0;
            shift_k_idx = 0;
            k_idx       = 0;
            x_idx       = 0;
        end

        `sauria_info(message_id, $sformatf("Updated PSUMS Counters SHIFT_K: %0d K:%0d X:%0d Act_Rep_Idx: %0d Wei_Rep_Idx: %0d", 
        shift_k_idx, k_idx, x_idx, act_rep_idx, wei_rep_idx))

    endfunction

    virtual function void clear_counters();
        act_rep_idx = 0;
        shift_k_idx = 0;
        k_idx       = 0;
        x_idx       = 0;
    endfunction

endclass