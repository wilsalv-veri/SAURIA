class sauria_data_generator extends uvm_object;

    `uvm_object_utils(sauria_data_generator)

    string message_id = "SAURIA_DATA_GENERATOR";
    
    sauria_computation_params    computation_params;
    sauria_tensor_mem_seq_item   tensor_item;
    sauria_axi4_rd_txn_seq_item  rd_txn_item;

    sauria_axi4_data_t           rdata;
    
    data_gen_mode_t              data_gen_mode;
    int                          byte_idx;

    function new(string name="sauria_data_generator");
        super.new(name);
    endfunction

    virtual function void configure_generator(sauria_tensor_mem_seq_item tensor_item, sauria_axi4_rd_txn_seq_item  rd_txn_item, sauria_computation_params computation_params);
        this.tensor_item        = tensor_item;
        this.rd_txn_item        = rd_txn_item;
        this.computation_params = computation_params;
    endfunction

    virtual function void set_data_gen_mode(data_gen_mode_t data_gen_mode);
        this.data_gen_mode = data_gen_mode;
    endfunction

    virtual function sauria_axi4_data_t gen_read_data();
        int num_bytes    = 2**rd_txn_item.rd_addr_item.arsize;
        int last_data_idx;
        int elem_start_idx;
        rdata = sauria_axi4_data_t'(0);

        case(tensor_item.tensor_type)
            IFMAPS:  last_data_idx = num_bytes / ($bits(sauria_ifmaps_elem_data_t)  / BYTE);
            WEIGHTS: last_data_idx = num_bytes / ($bits(sauria_weights_elem_data_t) / BYTE);
            PSUMS:   last_data_idx = num_bytes / ($bits(sauria_psums_elem_data_t)   / BYTE);
        endcase
        
        `sauria_info(message_id, $sformatf("ARSIZE: %0d Last_Data_Idx: %0d",rd_txn_item.rd_addr_item.arsize, last_data_idx))

        for(int data_idx=0; data_idx < last_data_idx; data_idx++)begin
            
            case(tensor_item.tensor_type)
                IFMAPS: begin
                    elem_start_idx = data_idx*$bits(sauria_ifmaps_elem_data_t);
                    rdata[elem_start_idx +: $bits(sauria_ifmaps_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
                WEIGHTS: begin
                    elem_start_idx = data_idx*$bits(sauria_weights_elem_data_t);
                    rdata[elem_start_idx +: $bits(sauria_weights_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
                PSUMS: begin
                    elem_start_idx = data_idx*$bits(sauria_psums_elem_data_t);
                    rdata[elem_start_idx +: $bits(sauria_psums_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
            endcase
        end
        byte_idx++;
        return rdata; 
    endfunction
 
    virtual function longint unsigned get_int_elem_data();
        case(data_gen_mode)
            RAND: return get_rand_int_elem_data();
            ADDR_AS_DATA: return get_addr_int_elem_data();
            BAD_PATTERN: return get_bad_pattern_int_elem_data();
            INCR_PATTERN: return get_incr_count_int_elem_data();
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

    virtual function real get_fp_elem_data();
    
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

endclass