class sauria_data_generator extends uvm_object;

    `uvm_object_utils(sauria_data_generator)

    string message_id = "SAURIA_DATA_GENERATOR";
    
    sauria_computation_params    computation_params;
    sauria_tensor_mem_seq_item   tensor_item;
    sauria_tensor_type_t         prev_tensor_type;

    sauria_axi4_rd_txn_seq_item  rd_txn_item;

    sauria_axi4_data_t           rdata;
    
    int_data_gen_mode_t          int_ifmaps_data_mode;
    int_data_gen_mode_t          int_weights_data_mode;
    int_data_gen_mode_t          int_psums_data_mode;
   
    fp_data_gen_mode_t           fp_ifmaps_data_mode;
    fp_data_gen_mode_t           fp_weights_data_mode;
    fp_data_gen_mode_t           fp_psums_data_mode;
    int                          byte_idx;

    bit                          plusarg_registry_is_configured;

    string data_mode_plusargs[$] = '{"IFMAPS_DATA_MODE", 
                                    "WEIGHTS_DATA_MODE", 
                                    "PSUMS_DATA_MODE"};

    
    function new(string name="sauria_data_generator");
        super.new(name);
        plusarg_registry_is_configured = 0;
    endfunction

    virtual function void configure_generator(sauria_tensor_mem_seq_item tensor_item, sauria_axi4_rd_txn_seq_item  rd_txn_item, sauria_computation_params computation_params);
        this.tensor_item        = tensor_item;
        this.rd_txn_item        = rd_txn_item;
        this.computation_params = computation_params;
        register_data_mode_plusargs();
        set_data_gen_mode();
    endfunction

    virtual function void register_data_mode_plusargs();
        string data_mode_values[$];
        int min_numeric_value;
        int max_numeric_value;

        if (plusarg_registry_is_configured)
            return;

        if (INT_ARITHMETIC)
            sauria_plusarg_utils::get_int_data_mode_values(data_mode_values, min_numeric_value, max_numeric_value);
        else
            sauria_plusarg_utils::get_fp_data_mode_values(data_mode_values, min_numeric_value, max_numeric_value);

        foreach (data_mode_plusargs[idx]) begin
            sauria_plusarg_utils::register_plusarg(data_mode_plusargs[idx]);
            sauria_plusarg_utils::register_plusarg_values(data_mode_plusargs[idx], data_mode_values, min_numeric_value, max_numeric_value);
        end

        plusarg_registry_is_configured = 1;
    endfunction

    virtual function void set_data_gen_mode();
        int mode_values[3];
        initialize_mode_values(mode_values);
        plusarg_override_mode_values(mode_values);

        if (INT_ARITHMETIC) begin
            set_int_data_gen_mode(int_data_gen_mode_t'(mode_values[0]), int_data_gen_mode_t'(mode_values[1]), int_data_gen_mode_t'(mode_values[2]));
        end else begin
            set_fp_data_gen_mode(fp_data_gen_mode_t'(mode_values[0]), fp_data_gen_mode_t'(mode_values[1]), fp_data_gen_mode_t'(mode_values[2]));
        end
    endfunction

    virtual function void set_int_data_gen_mode(int_data_gen_mode_t int_ifmaps_data_mode, int_data_gen_mode_t int_weights_data_mode, int_data_gen_mode_t int_psums_data_mode);
        this.int_ifmaps_data_mode  = int_ifmaps_data_mode;
        this.int_weights_data_mode = int_weights_data_mode;
        this.int_psums_data_mode   = int_psums_data_mode;
    endfunction

    virtual function void set_fp_data_gen_mode(fp_data_gen_mode_t fp_ifmaps_data_mode, fp_data_gen_mode_t fp_weights_data_mode, fp_data_gen_mode_t fp_psums_data_mode);
        this.fp_ifmaps_data_mode  = fp_ifmaps_data_mode;
        this.fp_weights_data_mode = fp_weights_data_mode;
        this.fp_psums_data_mode   = fp_psums_data_mode;
    endfunction
    
    virtual function sauria_axi4_data_t gen_read_data();
        int num_bytes    = DATA_AXI_BYTE_NUM; //2**rd_txn_item.rd_addr_item.arsize;
        int last_elem_idx;
        int elem_base_offset;
        rdata = sauria_axi4_data_t'(0);

        if (tensor_item.tensor_type.name != prev_tensor_type.name) byte_idx = 0;
        prev_tensor_type = tensor_item.tensor_type;
        
        case(tensor_item.tensor_type)
            IFMAPS:  last_elem_idx = num_bytes / ($bits(sauria_ifmaps_elem_data_t)  / BYTE);
            WEIGHTS: last_elem_idx = num_bytes / ($bits(sauria_weights_elem_data_t) / BYTE);
            PSUMS:   last_elem_idx = num_bytes / ($bits(sauria_psums_elem_data_t)   / BYTE);
        endcase
        
        for(int elem_idx=0; elem_idx < last_elem_idx; elem_idx++)begin
            
            case(tensor_item.tensor_type)
                IFMAPS: begin
                    if ((elem_idx % sauria_pkg::SRAMA_N == 0) && (elem_idx > 0)) byte_idx++; 
                    elem_base_offset = elem_idx*$bits(sauria_ifmaps_elem_data_t);
                    rdata[elem_base_offset +: $bits(sauria_ifmaps_elem_data_t)] = INT_ARITHMETIC ?  get_int_elem_data(int_ifmaps_data_mode) : get_fp_elem_data(fp_ifmaps_data_mode);
                end
                WEIGHTS: begin
                    if ((elem_idx % sauria_pkg::SRAMB_N == 0) && (elem_idx > 0)) byte_idx++; 
                    elem_base_offset = elem_idx*$bits(sauria_weights_elem_data_t);
                    rdata[elem_base_offset +: $bits(sauria_weights_elem_data_t)] = INT_ARITHMETIC ? get_int_elem_data(int_weights_data_mode) : get_fp_elem_data(fp_weights_data_mode);
                end
                PSUMS: begin
                    if ((elem_idx % sauria_pkg::SRAMC_N == 0) && (elem_idx > 0)) byte_idx++; 
                    elem_base_offset = elem_idx*$bits(sauria_psums_elem_data_t);
                    rdata[elem_base_offset +: $bits(sauria_psums_elem_data_t)] = INT_ARITHMETIC ? get_int_elem_data(int_psums_data_mode) : get_fp_elem_data(fp_psums_data_mode);
                end
            endcase
        end
        byte_idx += 2;
        return rdata; 
    endfunction
 
    virtual function longint unsigned get_int_elem_data(int_data_gen_mode_t int_data_mode);
        case(int_data_mode)
            RAND_INT_DATA_MODE:    return get_rand_int_data_mode();
            RAND_INT:              return get_rand_int_elem_data();
            ADDR_AS_DATA:          return get_addr_int_elem_data();
            BAD_PATTERN:           return get_bad_pattern_int_elem_data();
            INCR_PATTERN:          return get_incr_count_int_elem_data();
            SING_NIB_INCR_PATTERN: return get_single_nib_incr_count_int_elem_data();
            ALL_ONES:              return get_ones_int_elem_data();
            ALL_TWOS:              return get_twos_int_elem_data();
        endcase
    endfunction

    virtual function sauria_fp_elem_data_t get_fp_elem_data(fp_data_gen_mode_t fp_data_mode);
        case(fp_data_mode)
            RAND_FP_DATA_MODE:  return get_rand_fp_elem_data();
            RAND_FP:            return get_rand_fp_elem_data();
            FP_POS_ZERO:        return FP16_POS_ZERO;
            FP_NEG_ZERO:        return FP16_NEG_ZERO;
            FP_ONE:             return get_one_fp_elem_data();
            FP_ONE_W_FRAC_COMP: return get_one_w_frac_comp_fp_elem_data();
            FP_NEG_ONE:         return get_neg_one_fp_elem_data();
            FP_HALF:            return get_half_fp_elem_data();
            FP_TWO:             return get_two_fp_elem_data();
            FP_MIN_NORM:        return FP16_MIN_NORM;
            FP_MAX_SUB:         return FP16_MAX_SUB;
            FP_MIN_SUB:         return FP16_MIN_SUB;
            FP_MAX_FIN:         return FP16_MAX_FIN;
            FP_POS_INF:         return FP16_POS_INF;
            FP_NEG_INF:         return FP16_NEG_INF;
            FP_QNAN:            return FP16_QNAN;
        endcase
    endfunction

    virtual function longint unsigned get_rand_int_data_mode();
        int rand_val = $urandom_range(1,7);
        case(rand_val)
            0: return get_rand_int_elem_data();
            1: return get_addr_int_elem_data();
            2: return get_addr_int_elem_data();
            3: return get_bad_pattern_int_elem_data();
            4: return get_incr_count_int_elem_data(); 
            5: return get_single_nib_incr_count_int_elem_data();
            6: return get_ones_int_elem_data();
            7: return get_twos_int_elem_data();
        endcase
    endfunction 

    virtual function longint unsigned get_rand_int_elem_data();
        int elem_size      = get_elem_size();
        int max_rand_value = (2**elem_size) - 1;
        return $urandom_range(max_rand_value);
    endfunction

    virtual function longint unsigned get_addr_int_elem_data();
        return rd_txn_item.rd_addr_item.araddr;
    endfunction

    virtual function longint unsigned get_bad_pattern_int_elem_data();
        return 32'hdeadbeef;
    endfunction
    
    virtual function longint unsigned get_incr_count_int_elem_data();
        int curr_byte_idx = byte_idx;
        int last_idx      = (get_elem_size() / BYTE) * 2;
        longint unsigned elem_value;

        for (int elem_byte_idx=0; elem_byte_idx < last_idx; elem_byte_idx++)begin
            elem_value |= (curr_byte_idx % 16);

            if(elem_byte_idx != (last_idx - 1)) elem_value <<= 4;
        end
        byte_idx++;
        return elem_value;
    endfunction

    virtual function longint unsigned get_single_nib_incr_count_int_elem_data();
        longint unsigned elem_value = (byte_idx % 16);
        byte_idx++;
        return elem_value;
    endfunction

    virtual function longint unsigned get_ones_int_elem_data();
        return 1;
    endfunction

    virtual function longint unsigned get_twos_int_elem_data();
        return 2;
    endfunction

    virtual function sauria_fp_elem_data_t get_rand_fp_elem_data();
        int rand_val = $urandom_range(0,12);
        case(rand_val)
            0:  return FP16_POS_ZERO;
            1:  return FP16_NEG_ZERO;
            2:  return FP16_ONE;
            3:  return FP16_NEG_ONE;
            4:  return FP16_TWO;
            5:  return FP16_HALF;
            6:  return FP16_MIN_NORM;
            7:  return FP16_MAX_SUB;
            8:  return FP16_MIN_SUB;
            9:  return FP16_MAX_FIN;
            10: return FP16_POS_INF;
            11: return FP16_NEG_INF;
            12: return FP16_QNAN;
        endcase
    endfunction 

    virtual function sauria_fp_elem_data_t get_one_fp_elem_data();
        return sauria_fp_elem_data_t'('h3c00);
    endfunction

    virtual function sauria_fp_elem_data_t get_one_w_frac_comp_fp_elem_data();
        return sauria_fp_elem_data_t'('h3d00);
    endfunction

    virtual function sauria_fp_elem_data_t get_half_fp_elem_data();
        return sauria_fp_elem_data_t'('h3800);
    endfunction

    virtual function sauria_fp_elem_data_t get_neg_one_fp_elem_data();
        return sauria_fp_elem_data_t'('hbc00);
    endfunction

    virtual function sauria_fp_elem_data_t get_two_fp_elem_data();
        return sauria_fp_elem_data_t'('h4000);
    endfunction

    virtual function int get_elem_size();
        case(tensor_item.tensor_type)
            IFMAPS : return $bits(sauria_ifmaps_elem_data_t);
            WEIGHTS: return $bits(sauria_weights_elem_data_t);
            PSUMS  : return $bits(sauria_psums_elem_data_t);
        endcase
    endfunction

    virtual function void set_tensor_type(sauria_axi4_addr_t araddr);
        if ((araddr >= computation_params.start_SRAMA_addr) && (araddr < computation_params.start_SRAMB_addr))
            tensor_item.tensor_type = IFMAPS;
        else if ((araddr >= computation_params.start_SRAMB_addr) && (araddr < computation_params.start_SRAMC_addr))
            tensor_item.tensor_type = WEIGHTS;
        else if (araddr >= computation_params.start_SRAMC_addr)
            tensor_item.tensor_type = PSUMS;      
    endfunction

    virtual function void initialize_mode_values(ref int mode_values[3]);
        mode_values[0] = int'(IFMAPS_DATA_MODE);
        mode_values[1] = int'(WEIGHTS_DATA_MODE);
        mode_values[2] = int'(PSUMS_DATA_MODE);
    endfunction

    virtual function void plusarg_override_mode_values(ref int mode_values[3]);
        string plusarg_raw_value;
        sauria_plusarg_utils::plusarg_override_status_t override_status;
        int_data_gen_mode_t int_mode;
        fp_data_gen_mode_t fp_mode;

        for (int idx = 0; idx < data_mode_plusargs.size(); idx++) begin
            override_status = sauria_plusarg_utils::apply_registered_plusarg_override(data_mode_plusargs[idx], mode_values[idx], plusarg_raw_value);
            if (INT_ARITHMETIC) begin
                int_mode = int_data_gen_mode_t'(mode_values[idx]);
                if (override_status == sauria_plusarg_utils::PLUSARG_APPLIED)
                    `sauria_info(message_id, $sformatf("Override applied: %s=%s (%0d)", data_mode_plusargs[idx], int_mode.name(), mode_values[idx]))
                else if (override_status == sauria_plusarg_utils::PLUSARG_INVALID)
                    `sauria_warning(message_id, $sformatf("Invalid %s override value '%s'. Keeping default mode %s (%0d)", data_mode_plusargs[idx], plusarg_raw_value, int_mode.name(), mode_values[idx]))
            end else begin
                fp_mode = fp_data_gen_mode_t'(mode_values[idx]);
                if (override_status == sauria_plusarg_utils::PLUSARG_APPLIED)
                    `sauria_info(message_id, $sformatf("Override applied: %s=%s (%0d)", data_mode_plusargs[idx], fp_mode.name(), mode_values[idx]))
                else if (override_status == sauria_plusarg_utils::PLUSARG_INVALID)
                    `sauria_warning(message_id, $sformatf("Invalid %s override value '%s'. Keeping default mode %s (%0d)", data_mode_plusargs[idx], plusarg_raw_value, fp_mode.name(), mode_values[idx]))
            end
        end
    endfunction
    
endclass