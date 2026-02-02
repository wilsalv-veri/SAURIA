class sauria_data_generator extends uvm_object;

    `uvm_object_utils(sauria_data_generator)

    string message_id = "SAURIA_DATA_GENERATOR";
    
    sauria_computation_params    computation_params;
    sauria_tensor_mem_seq_item   tensor_item;
    sauria_axi4_rd_txn_seq_item  rd_txn_item;

    function new(string name="sauria_data_generator");
        super.new(name);
    endfunction

    virtual function void configure_generator(sauria_tensor_mem_seq_item tensor_item, sauria_axi4_rd_txn_seq_item  rd_txn_item, sauria_computation_params computation_params);
        this.tensor_item        = tensor_item;
        this.rd_txn_item        = rd_txn_item;
        this.computation_params = computation_params;
    endfunction

    virtual function void gen_read_data();
        int last_data_idx = $clog2(rd_txn_item.rd_addr_item.arsize);
        int elem_start_idx;
        int elem_end_idx;
               
        for(int data_idx=0; data_idx < last_data_idx; data_idx++)begin
            
            case(tensor_item.tensor_type)
                IFMAPS: begin
                    elem_start_idx = data_idx*$bits(sauria_ifmaps_elem_data_t);
                    rd_txn_item.rd_data_item.rdata[elem_start_idx +: $bits(sauria_ifmaps_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
                WEIGHTS: begin
                    elem_start_idx = data_idx*$bits(sauria_weights_elem_data_t);
                    rd_txn_item.rd_data_item.rdata[elem_start_idx +: $bits(sauria_weights_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
                PSUMS: begin
                    elem_start_idx = data_idx*$bits(sauria_psums_elem_data_t);
                    rd_txn_item.rd_data_item.rdata[elem_start_idx +: $bits(sauria_psums_elem_data_t)] = `ARITHMETIC ? get_fp_elem_data() : get_int_elem_data();
                end
            endcase
        end
            
    endfunction
 
    virtual function longint unsigned get_int_elem_data;
        int elem_size      = get_elem_size();
        int max_rand_value = (2**elem_size) - 1;
        return $urandom_range(max_rand_value);
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