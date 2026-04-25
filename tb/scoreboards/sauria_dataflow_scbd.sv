class sauria_dataflow_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_dataflow_scbd)

    string message_id = "SAURIA_DATAFLOW_SCBD";

    `uvm_analysis_imp_decl(_dma_rd_addr)
    uvm_analysis_imp_dma_rd_addr #(sauria_axi4_rd_addr_seq_item , sauria_dataflow_scbd) receive_dma_rd_addr;
   
    `uvm_analysis_imp_decl(_dma_wr_addr)
    uvm_analysis_imp_dma_wr_addr #(sauria_axi4_wr_addr_seq_item , sauria_dataflow_scbd) receive_dma_wr_addr;
   
    sauria_dataflow_model                 dataflow_model;
    sauria_gemm_tensor_ptr_adapter_model  dma_gemm_adapter_model;
    sauria_dma_mem_req_shape_model        dma_req_shape_model;

    sauria_computation_params      computation_params;

    function new(string name="sauria_dataflow_scbd", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    local function string get_tensor_name(sauria_tensor_type_t tensor);
        case (tensor)
            IFMAPS:  return "IFMAPS";
            WEIGHTS: return "WEIGHTS";
            PSUMS:   return "PSUMS";
            default: return "UNKNOWN";
        endcase
    endfunction

    local function string get_access_dir_name(gemm_access_dir_t access_dir);
        case (access_dir)
            GEMM_ACCESS_READ:  return "READ";
            GEMM_ACCESS_WRITE: return "WRITE";
            default:           return "UNKNOWN";
        endcase
    endfunction

    local function string format_gemm_debug_map(gemm_sauria_addr_map_t debug_map);
        return $sformatf("tensor=%s dir=%s m_tile=%0d k_tile=%0d n_tile=%0d m_blk=%0d k_blk=%0d n_blk=%0d sauria_tile=%0d reported_psums_tile=%0d intra_off=0x%0h tile_off=0x%0h byte_off=0x%0h row_addr=0x%0h final_c_write=%0d",
                         get_tensor_name(debug_map.tensor),
                         get_access_dir_name(debug_map.access_dir),
                         debug_map.m_tile_idx,
                         debug_map.k_tile_idx,
                         debug_map.n_tile_idx,
                         debug_map.m_block_idx,
                         debug_map.k_block_idx,
                         debug_map.n_block_idx,
                         debug_map.sauria_tile_idx,
                         debug_map.reported_psums_tile_idx,
                         debug_map.intra_tile_offset,
                         debug_map.tile_offset,
                         debug_map.elem_byte_offset,
                         debug_map.row_addr,
                         debug_map.final_c_write);
    endfunction

    local function string format_gemm_shadow_context(dma_req_addr_check_result_t gemm_result);
        if (!gemm_result.debug_map_valid)
            return "GEMM_MAP: unavailable";

        return $sformatf("GEMM_MAP: %s", format_gemm_debug_map(gemm_result.debug_map));
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dataflow_model         = sauria_dataflow_model::type_id::create("sauria_dataflow_model");
        dma_gemm_adapter_model = sauria_gemm_tensor_ptr_adapter_model::type_id::create("sauria_gemm_tensor_ptr_adapter_model");
        dma_req_shape_model = sauria_dma_mem_req_shape_model::type_id::create("sauria_dma_mem_req_shape_model");

        receive_dma_rd_addr = new("RECEIVE_DMA_RD_ADDR_ANALYSIS_IMP", this);
        receive_dma_wr_addr = new("RECEIVE_DMA_WR_ADDR_ANALYSIS_IMP", this);
        
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")

        dataflow_model.set_computation_params(computation_params);
        dma_gemm_adapter_model.set_computation_params(computation_params);
        dma_req_shape_model.set_computation_params(computation_params);
    endfunction
    
    function write_dma_rd_addr(sauria_axi4_rd_addr_seq_item dma_rd_addr);
        dma_req_addr_check_result_t result;
        dma_req_addr_check_result_t gemm_result;

        result = dataflow_model.observe_rd_addr(dma_rd_addr);
        gemm_result = dma_gemm_adapter_model.observe_rd_addr(dma_rd_addr);

        if (result.exp_addr != gemm_result.exp_addr)
            `sauria_error(message_id, $sformatf("DMA Read Shadow Model Mismatch Legacy: 0x%0h GEMM: 0x%0h %s",
                                                result.exp_addr,
                                                gemm_result.exp_addr,
                                                format_gemm_shadow_context(gemm_result)))

        if (result.burst_mismatch != gemm_result.burst_mismatch)
            `sauria_error(message_id, $sformatf("DMA Read Shadow Burst Check Mismatch Legacy: %0d GEMM: %0d", result.burst_mismatch, gemm_result.burst_mismatch))

        if(result.addr_mismatch)
            `sauria_error(message_id, $sformatf("DMA Read Req Address Mismatch Exp: 0x%0h Act: 0x%0h", result.exp_addr, dma_rd_addr.araddr))

        if (result.burst_mismatch)
            `sauria_error(message_id, "Got Non INCR Burst Mode ")
    endfunction

    function write_dma_wr_addr(sauria_axi4_wr_addr_seq_item dma_wr_addr);
        dma_req_addr_check_result_t result;
        dma_req_addr_check_result_t gemm_result;

        result = dataflow_model.observe_wr_addr(dma_wr_addr);
        gemm_result = dma_gemm_adapter_model.observe_wr_addr(dma_wr_addr);

        if (result.exp_addr != gemm_result.exp_addr)
            `sauria_error(message_id, $sformatf("DMA Write Shadow Model Mismatch Legacy: 0x%0h GEMM: 0x%0h %s",
                                                result.exp_addr,
                                                gemm_result.exp_addr,
                                                format_gemm_shadow_context(gemm_result)))

        if (result.psums_tile_idx != gemm_result.psums_tile_idx)
            `sauria_error(message_id, $sformatf("DMA Write Shadow Tile Index Mismatch Legacy: %0d GEMM: %0d %s",
                                                result.psums_tile_idx,
                                                gemm_result.psums_tile_idx,
                                                format_gemm_shadow_context(gemm_result)))

        if (result.burst_mismatch != gemm_result.burst_mismatch)
            `sauria_error(message_id, $sformatf("DMA Write Shadow Burst Check Mismatch Legacy: %0d GEMM: %0d", result.burst_mismatch, gemm_result.burst_mismatch))

        if(result.addr_mismatch)
            `sauria_error(message_id, $sformatf("DMA Write Req Address Mismatch Exp: 0x%0h Act: 0x%0h PSUMS_TILE_IDX: %0d", result.exp_addr, dma_wr_addr.awaddr, result.psums_tile_idx))
            
        if (result.burst_mismatch)
            `sauria_error(message_id, "Got Non INCR Burst Mode ")
    endfunction

endclass