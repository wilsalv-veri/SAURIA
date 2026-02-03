class sauria_dma_mem_req_shape_model extends sauria_base_model;

    `uvm_object_utils(sauria_dma_mem_req_shape_model)
 
    sauria_tensor_type_t elem_type;

    function new(string name="sauria_dma_mem_req_shape_model");
        super.new(name);
        message_id = "SAURIA_DMA_MEM_REQ_SHAPE_MODEL";
    endfunction

    virtual function sauria_axi_len_t get_exp_len(sauria_axi4_addr_t mem_req_rd_addr);
        set_elem_type(mem_req_rd_addr);
        return get_num_beats();
    endfunction

    virtual function sauria_axi_len_t get_exp_size(sauria_axi4_addr_t mem_req_rd_addr);
        int ett, btt;
        set_elem_type(mem_req_rd_addr);
        ett = get_ett();
        btt = get_btt(ett);
        return $clog2(btt);
    endfunction
    
    virtual function void set_elem_type(sauria_axi4_addr_t mem_req_rd_addr);
        case(mem_req_rd_addr & sauria_addr_pkg::SAURIA_DMA_ADDR_MASK)
            start_SRAMA_addr: elem_type =  IFMAPS;
            start_SRAMB_addr: elem_type =  WEIGHTS;
            start_SRAMC_addr: elem_type =  PSUMS;
        endcase;
    endfunction

    /* 
    virtual function sauria_axi_len_t get_ifmaps_beats();
        int ett = ifmap_X;
        return get_num_beats(ett, IFMAPS);
    endfunction

    virtual function sauria_axi_len_t get_weights_beats();
        int ett = Ck_eq ? weights_tile_size : weights_K;
        return get_num_beats(ett, WEIGHTS);
    endfunction

    virtual function sauria_axi_len_t get_psums_beats();
        int ett = (Cw_eq && Ch_eq) ? psums_tile_size: psums_X;
        return get_num_beats(ett, PSUMS);
    endfunction
    */

    virtual function sauria_axi_len_t get_num_beats();
        int ett = get_ett();
        int btt = get_btt(ett);
        int transfers  = $floor(btt / DATA_AXI_BYTE_NUM);
        return (transfers > 0) ? transfers - 1 : transfers;
    endfunction

    virtual function int get_btt(int ett);
        return ett*(get_elem_size(elem_type)/BYTE);
    endfunction

    virtual function int get_ett();
        case(elem_type)
            IFMAPS : return ifmap_X;
            WEIGHTS: return Ck_eq ? weights_tile_size : weights_K;
            PSUMS  : return (Cw_eq && Ch_eq) ? psums_tile_size: psums_X;
        endcase
    endfunction

    virtual function int get_elem_size(sauria_tensor_type_t elem_type);
        case(elem_type)
            IFMAPS: return $bits(sauria_ifmaps_elem_data_t);
            WEIGHTS:return $bits(sauria_weights_elem_data_t);
            PSUMS:  return $bits(sauria_psums_elem_data_t);
        endcase
    endfunction

endclass