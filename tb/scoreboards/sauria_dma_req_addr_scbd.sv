class sauria_dma_req_addr_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_dma_req_addr_scbd)

    string message_id = "SAURIA_DMA_REQ_ADDR_SCBD";

    `uvm_analysis_imp_decl(_dma_rd_addr)
    uvm_analysis_imp_dma_rd_addr #(sauria_axi4_rd_addr_seq_item , sauria_dma_req_addr_scbd) receive_dma_rd_addr;
   
    `uvm_analysis_imp_decl(_dma_wr_addr)
    uvm_analysis_imp_dma_wr_addr #(sauria_axi4_wr_addr_seq_item , sauria_dma_req_addr_scbd) receive_dma_wr_addr;
   
    sauria_tensor_ptr_model        dma_ptr_model;
    sauria_dma_mem_req_shape_model dma_req_shape_model;

    sauria_computation_params      computation_params;

    sauria_axi4_addr_t             tensor_ptr_next_exp_rd_addr;
    sauria_axi4_addr_t             tensor_ptr_next_exp_wr_addr;
    
    sauria_axi_len_t               dma_rd_req_exp_len;
    sauria_axi_len_t               dma_wr_req_exp_len;

    sauria_axi_size_t              dma_rd_req_exp_size;
    sauria_axi_size_t              dma_wr_req_exp_size;

    sauria_axi4_rd_addr_seq_item   dma_rd_addr;
    sauria_axi4_wr_addr_seq_item   dma_wr_addr;

    function new(string name="sauria_dma_rd_addr_scbd", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        dma_ptr_model       = sauria_tensor_ptr_model::type_id::create("sauria_tensor_ptr_model");
        dma_req_shape_model = sauria_dma_mem_req_shape_model::type_id::create("sauria_dma_mem_req_shape_model");

        receive_dma_rd_addr = new("RECEIVE_DMA_RD_ADDR_ANALYSIS_IMP", this);
        receive_dma_wr_addr = new("RECEIVE_DMA_WR_ADDR_ANALYSIS_IMP", this);
        
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    endfunction

    virtual task run_phase(uvm_phase phase);
        wait_params_to_be_shared();
        configure_models();
    endtask

    virtual task wait_params_to_be_shared();
        wait(computation_params.tensors_start_addr_shared);
        wait(computation_params.shared);
    endtask

    virtual function void configure_models();
        dma_ptr_model.configure_model(computation_params);
        dma_req_shape_model.configure_model(computation_params);
    endfunction
    
    function write_dma_rd_addr(sauria_axi4_rd_addr_seq_item dma_rd_addr);
        
        check_model_configured();
        this.dma_rd_addr            = dma_rd_addr;
        tensor_ptr_next_exp_rd_addr = dma_ptr_model.get_next_exp_rd_address();
        dma_rd_req_exp_len          = dma_req_shape_model.get_exp_len(dma_rd_addr.araddr);
        dma_rd_req_exp_size         = dma_req_shape_model.get_exp_size(dma_rd_addr.araddr);
        check_rd_address();
    endfunction

    function write_dma_wr_addr(sauria_axi4_wr_addr_seq_item dma_wr_addr);
        
        check_model_configured();
        this.dma_wr_addr            = dma_wr_addr;
        tensor_ptr_next_exp_wr_addr = dma_ptr_model.get_next_exp_wr_address();
        dma_wr_req_exp_len          = dma_req_shape_model.get_exp_len(dma_wr_addr.awaddr);
        dma_wr_req_exp_size         = dma_req_shape_model.get_exp_size(dma_wr_addr.awaddr);
        check_wr_address();
    endfunction

    virtual function void check_rd_address();
        if(tensor_ptr_next_exp_rd_addr != dma_rd_addr.araddr)
            `sauria_error(message_id, $sformatf("DMA Read Req Address Mismatch Exp: 0x%0h Act: 0x%0h", tensor_ptr_next_exp_rd_addr, dma_rd_addr.araddr))
        
        if(dma_rd_req_exp_len != dma_rd_addr.arlen)
            `sauria_error(message_id, $sformatf("DMA Read Req Len Mismatch Exp: 0x%0h Act: 0x%0h", dma_rd_req_exp_len, dma_rd_addr.arlen))

        if(dma_rd_req_exp_size != dma_rd_addr.arsize)
            `sauria_error(message_id, $sformatf("DMA Read Req Size Mismatch Exp: 0x%0h Act: 0x%0h", dma_rd_req_exp_size, dma_rd_addr.arsize))

        if (dma_rd_addr.arburst != INCR)
            `sauria_error(message_id, "Got Non INCR Burst Mode ")
    endfunction

    virtual function void check_wr_address();
        if(tensor_ptr_next_exp_wr_addr != dma_wr_addr.awaddr)
            `sauria_error(message_id, $sformatf("DMA Write Req Address Mismatch Exp: 0x%0h Act: 0x%0h PSUMS_TILE_IDX: %0d", tensor_ptr_next_exp_wr_addr, dma_wr_addr.awaddr, dma_ptr_model.get_psums_tile_idx()))
            
        if(dma_wr_req_exp_len != dma_wr_addr.awlen)
            `sauria_error(message_id, $sformatf("DMA Write Req Len Mismatch Exp: 0x%0h Act: 0x%0h", dma_wr_req_exp_len, dma_wr_addr.awlen))

        if(dma_wr_req_exp_size != dma_wr_addr.awsize)
            `sauria_error(message_id, $sformatf("DMA Read Req Size Mismatch Exp: 0x%0h Act: 0x%0h", dma_wr_req_exp_size, dma_wr_addr.awsize))

        if (dma_wr_addr.awburst != INCR)
            `sauria_error(message_id, "Got Non INCR Burst Mode ")
    endfunction

    virtual function void check_model_configured();
        if (!(computation_params.tensors_start_addr_shared && computation_params.shared))
            `sauria_fatal(message_id, "Tensor Ptr Model Not Configured Yet. Ignore Results!")
    endfunction

endclass