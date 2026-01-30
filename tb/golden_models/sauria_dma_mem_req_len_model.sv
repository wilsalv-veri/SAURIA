class sauria_dma_mem_req_len_model extends sauria_base_model;

    `uvm_object_utils(sauria_dma_mem_req_len_model)
 
    function new(string name="sauria_dma_mem_req_len_model");
        super.new(name);
        message_id = "SAURIA_DMA_MEM_REQ_LEN_MODEL";
    endfunction

    virtual function sauria_axi_len_t get_exp_len(sauria_axi4_addr_t mem_req_rd_addr);
        case(mem_req_rd_addr & sauria_addr_pkg::SAURIA_DMA_ADDR_MASK)
            start_SRAMA_addr: return get_ifmaps_btt();
            start_SRAMB_addr: return get_weights_btt();
            start_SRAMC_addr: return get_psums_btt();
        endcase
    endfunction

    virtual function sauria_axi_len_t get_ifmaps_btt();
        return $floor(ifmap_X*($bits(sauria_ifmaps_elem_data_t)/8) / DATA_AXI_BYTE_NUM); 
    endfunction

    virtual function sauria_axi_len_t get_weights_btt();
        return $floor(weights_K*($bits(sauria_weights_elem_data_t)/8) / DATA_AXI_BYTE_NUM); 
    endfunction

    virtual function sauria_axi_len_t get_psums_btt();
        return $floor(psums_X*($bits(sauria_psums_elem_data_t)/8) / DATA_AXI_BYTE_NUM); 
    endfunction

endclass