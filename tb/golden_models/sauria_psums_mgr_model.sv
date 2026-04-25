class sauria_psums_mgr_model extends uvm_object;

    `uvm_object_utils(sauria_psums_mgr_model)

    string message_id = "SAURIA_PSUMS_MGR_MODEL";

    sauria_computation_params   computation_params;
    bit                         is_configured;

    localparam RD_LAT        = 2;
    localparam PSUM_ELEM_LEN = $bits(sauria_psums_elem_data_t);

    psums_params_t            psums_params;
    sramc_data_t              shift_reg_data[$];     
    sramc_data_t              shift_reg_data_entry;      
    
    scan_chain_data_t         shift_reg_entry;
    
    sramc_addr_t              exp_next_rd_sramc_addr, exp_next_wr_sramc_addr;
    int                       shift_count;

    bit                       valid_psums_shift_reg_data;
    bit                       valid_preload_data;
   
    int                       num_tiles;
    int                       sramc_acceses_per_tile;
    int                       rd_done_count;
    int                       addr_zero_count;
    bit                       shift;

    arr_row_data_t             psums_inactive_cols;
    arr_col_data_t             psums_rows_active;

    sauria_axi4_lite_data_t    rd_shift_k_idx, rd_k_idx,rd_x_idx;
    sauria_axi4_lite_data_t    wr_shift_k_idx, wr_k_idx,wr_x_idx;
    sauria_axi4_lite_data_t    shift_k_idx,    k_idx,   x_idx;
    
    sauria_axi4_lite_data_t    shift_k_lim;
    sauria_axi4_lite_data_t    act_reps, wei_reps;
    
    sauria_axi4_lite_data_t    rd_act_rep_idx, rd_wei_rep_idx;
    sauria_axi4_lite_data_t    wr_act_rep_idx, wr_wei_rep_idx;
    sauria_axi4_lite_data_t       act_rep_idx, wei_rep_idx;

    function new(string name="sauria_psums_mgr_model");
        super.new(name);
    endfunction

    virtual function void set_computation_params(sauria_computation_params computation_params);
        this.computation_params = computation_params;
        is_configured           = 1'b0;
    endfunction

    virtual function void set_reps(sauria_axi4_lite_data_t act_reps,sauria_axi4_lite_data_t wei_reps);
       this.act_reps = act_reps;
       this.wei_reps = wei_reps;
    endfunction

    virtual function void configure(psums_params_t core_psums_params, 
                                 arr_col_data_t psums_rows_active,
                                 arr_row_data_t psums_inactive_cols);

        this.psums_params        = core_psums_params;
        this.psums_rows_active   = psums_rows_active;
        this.psums_inactive_cols = psums_inactive_cols;
        set_params();
        is_configured            = 1'b1;
    endfunction

    virtual function psums_mgr_sramc_read_result_t observe_sramc_read(sramc_addr_t sramc_addr,
                                                                       sramc_data_t sramc_rdata);
        psums_mgr_sramc_read_result_t result = '{default:'0};

        if (!try_ensure_configured())
            return result;

        result.addr_check_valid = is_valid_shift();
        if (result.addr_check_valid) begin
            result.exp_addr      = get_next_rd_sramc_addr();
            result.addr_mismatch = (result.exp_addr != sramc_addr);
        end

        add_psums_sram_rd_access(sramc_rdata);
        return result;
    endfunction

    virtual function psums_mgr_sramc_write_result_t observe_sramc_write(sramc_addr_t sramc_addr,
                                                                         sramc_data_t sramc_wdata);
        psums_mgr_sramc_write_result_t result = '{default:'0};

        if (!try_ensure_configured())
            return result;

        result.exp_addr      = get_next_wr_sramc_addr();
        result.addr_mismatch = (result.exp_addr != sramc_addr);

        add_psums_sram_wr_access();

        result.shift_reg_data_empty = is_shift_reg_data_empty();
        if (!result.shift_reg_data_empty) begin
            result.data_valid = 1'b1;
            result.exp_wdata  = get_shift_reg_data_entry();
        end

        return result;
    endfunction

    virtual function psums_mgr_preload_result_t observe_preload_values(scan_chain_data_t i_c_arr,
                                                                        scan_chain_data_t o_c_arr);
        psums_mgr_preload_result_t result = '{default:'0};

        if (!try_ensure_configured())
            return result;

        result.valid_preload_check = is_valid_preload_data();
        if (result.valid_preload_check)
            result.exp_preload_data = get_masked_preload_data();

        add_preload_values(i_c_arr);
        return result;
    endfunction

    virtual function psums_mgr_shift_reg_result_t observe_shift_reg(bit shift_done);
        psums_mgr_shift_reg_result_t result = '{default:'0};

        if (!try_ensure_configured())
            return result;

        if (shift_done && is_valid_psums_shift_reg_data()) begin
            result.valid_snapshot = 1'b1;
            for (int col = 0; col < sauria_pkg::X; col++)
                result.exp_shift_reg[col] = get_masked_shift_reg_data_entry(col);
        end

        return result;
    endfunction

    virtual function void set_params();
        sramc_acceses_per_tile = sauria_pkg::X; 
        shift_k_lim            = psums_params.tile_params.psums_ck_step * sramc_acceses_per_tile;
        num_tiles              = (psums_params.tile_params.psums_CX / SRAMA_N) * (psums_params.tile_params.psums_K  / SRAMB_N);
    
         
        `sauria_info(message_id, $sformatf("SRAMC_Acceses_Per_Tile: %0d Num_Tiles: %0d", sramc_acceses_per_tile, num_tiles))
    endfunction

    virtual function void add_psums_sram_rd_access(sramc_data_t sramc_rdata);
        
        shift = 1'b1;   
        valid_psums_shift_reg_data = 1'b1;
        valid_preload_data         = 1'b1;
                
        if (rd_done_count == RD_LAT - 1) begin
            
            shift_count   = -1; //Will become 0 
            rd_done_count =  0;
        end
        else if (shift_count < sauria_pkg::X) begin
            `sauria_info(message_id, "Pushing SRAMC Data")
                
            update_exp_sramc_addr(RD_TXN);

            if(shift_reg_data.size() == sauria_pkg::X) shift_reg_entry = shift_reg_data.pop_back();
            shift_reg_data.push_front(sramc_rdata);
                
        end
        else 
            rd_done_count++;

        shift_count++;
            
    endfunction

    virtual function void add_psums_sram_wr_access();
        update_exp_sramc_addr(WR_TXN);
    endfunction

    virtual function void add_preload_values(scan_chain_data_t i_c_arr);

        if ((shift_count <= sauria_pkg::X) && valid_preload_data) begin
        
            if (shift_reg_data.size() > 0) begin
                
                if(shift_count == (sauria_pkg::X - 1)) begin
                    valid_preload_data = 1'b0;
                    shift_count = 0;
                end
                else shift_count++;
            end 
            else `sauria_error(message_id, $sformatf("Scan Chain Active When Empty Shift Reg Shift_Count: %0d", shift_count))
        end
        shift_reg_data_entry = get_reversed_scan_chain_bus(i_c_arr);
        shift_reg_data.push_front(shift_reg_data_entry); 
        valid_psums_shift_reg_data = 1'b1;
       
    endfunction

    virtual function bit is_valid_shift();
        return shift && (shift_count < sauria_pkg::X);
    endfunction

    virtual function bit is_shift_reg_data_empty();
        return shift_reg_data.size() == 0;
    endfunction

    virtual function bit is_valid_preload_data();
        return (shift_count <= sauria_pkg::X) && valid_preload_data;
    endfunction

    virtual function bit is_valid_psums_shift_reg_data();
        bit ret_val = valid_psums_shift_reg_data;

        if (valid_psums_shift_reg_data)
            clear_psums_shift_reg_data_valid();
        return ret_val;
    endfunction

    virtual function sramc_addr_t get_next_rd_sramc_addr();
        return exp_next_rd_sramc_addr;
    endfunction

    virtual function sramc_addr_t get_next_wr_sramc_addr();
        return exp_next_wr_sramc_addr;
    endfunction

    virtual function void clear_psums_shift_reg_data_valid();
        valid_psums_shift_reg_data = 0;
        shift                      = 0;
    endfunction

    virtual function sramc_data_t get_shift_reg_data_entry();  
        return shift_reg_data.pop_back();
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

    virtual function scan_chain_data_t get_masked_preload_data();
        mask_inactive_preload_cols_rows(shift_count);
        return scan_chain_data_t'(shift_reg_data.pop_back());
    endfunction

    virtual function void mask_inactive_preload_cols_rows(int col);
        int data_col     = shift_reg_data.size() - 1;
        bit inactive_col = col > (sauria_pkg::X - psums_inactive_cols - 1);
        mask_inactive_cols_rows_data(data_col, inactive_col, 1'b1);
    endfunction

    virtual function scan_chain_data_t get_masked_shift_reg_data_entry(int col);
        mask_shift_reg_cols_rows(col);
        return shift_reg_data[col];
    endfunction

    virtual function void mask_shift_reg_cols_rows(int col);
        bit inactive_col = (valid_preload_data ? (col < psums_inactive_cols) : 1'b0);
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

    local function bit try_ensure_configured();
        if (is_configured)
            return 1'b1;

        if (computation_params == null)
            `sauria_fatal(message_id, "Computation params handle was not provided")

        if (!computation_params.main_controller_cfg_shared)
            return 1'b0;

        if (!computation_params.ifmaps_cfg_shared)
            return 1'b0;

        if (!computation_params.psums_mgr_cfg_shared)
            return 1'b0;

        set_reps(computation_params.act_reps, computation_params.wei_reps);
        configure(computation_params.core_psums_params,
                  arr_col_data_t'(computation_params.ifmaps_rows_active),
                  arr_row_data_t'(computation_params.psums_inactive_cols));
        return 1'b1;
    endfunction

endclass