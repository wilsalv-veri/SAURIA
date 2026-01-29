class sauria_axi4_driver extends uvm_driver #(sauria_tensor_mem_seq_item);

    `uvm_component_utils(sauria_axi4_driver)

    string message_id  = "SAURIA_AXI4_DRIVER";
    
    virtual sauria_axi4_ifc      sauria_axi4_mem_if;
    virtual sauria_subsystem_ifc sauria_ss_if;

    sauria_tensor_mem_seq_item   tensor_item;
    sauria_axi4_rd_addr_seq_item rd_addr_item;
    sauria_axi4_rd_data_seq_item rd_data_item;
     
    sauria_axi4_id_t             rid;
    sauria_axi4_addr_t           araddr;
    sauria_axi4_addr_t           next_addr;

    sauria_axi_len_t             exp_arlen;
    sauria_axi_len_t             act_arlen;
     
    sauria_axi_size_t            exp_arsize;
    sauria_axi_size_t            act_arsize;

    sauria_axi4_wr_addr_seq_item wr_addr_item;
    sauria_axi4_wr_data_seq_item wr_data_item;
    sauria_axi4_wr_rsp_seq_item  wr_rsp_item;
   

    function new(string name="sauria_axi4_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        tensor_item     = sauria_tensor_mem_seq_item::type_id::create("sauria_tensor_mem_seq_item");
        rd_addr_item    = sauria_axi4_rd_addr_seq_item::type_id::create("sauria_axi4_rd_addr_seq_item");
        rd_data_item    = sauria_axi4_rd_data_seq_item::type_id::create("sauria_axi4_rd_data_seq_item");
    
        wr_addr_item    = sauria_axi4_wr_addr_seq_item::type_id::create("sauria_axi4_wr_addr_seq_item");
        wr_data_item    = sauria_axi4_wr_data_seq_item::type_id::create("sauria_axi4_wr_data_seq_item");
        wr_rsp_item     = sauria_axi4_wr_rsp_seq_item::type_id::create("sauria_axi4_wr_rsp_seq_item");

        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(this, "", "sauria_axi4_mem_if", sauria_axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        @ (posedge sauria_ss_if.i_system_rstn);
        fork 
            forever @ (posedge sauria_ss_if.i_system_clk) begin
                service_axi4_mem_rd_req();
            end

            forever @ (posedge sauria_ss_if.i_system_clk) begin
                receive_axi4_mem_wr_req();
            end
        join
    endtask

    virtual task service_axi4_mem_rd_req();
        wait_arvalid();
        set_exp_arlen();
        get_rd_addr();
        tensor_model_checks();
        set_rd_data();  
    endtask

    virtual task wait_arvalid();
        sauria_axi4_mem_if.axi4_rd_addr_ch.arready <= 1'b1;
        @ (posedge sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid);
    endtask

    virtual function void tensor_model_checks();
        if (sauria_axi4_mem_if.axi4_rd_addr_ch.arburst != INCR)
            `sauria_error(message_id, "Got Non INCR Burst Mode ")
        
        //if (exp_arlen != act_arlen)
        //    `sauria_error(message_id, $sformatf("Expected AXI4_MEM RD Txn ARLEN Does not match Exp: %0d Act: %0d", exp_arlen, act_arlen))   
    endfunction

    virtual task get_rd_addr();
                
        sauria_axi4_mem_if.axi4_rd_addr_ch.arready <= 1'b0;
        rid        <= sauria_axi4_mem_if.axi4_rd_addr_ch.arid;
        act_arlen  <= sauria_axi4_mem_if.axi4_rd_addr_ch.arlen;
        act_arsize <= sauria_axi4_mem_if.axi4_rd_addr_ch.arsize;
        
        //The following fields are ignored for read requests
        /*
        sauria_axi4_mem_if.axi4_rd_addr_ch.arprot;
        sauria_axi4_mem_if.axi4_rd_addr_ch.arlock;
        sauria_axi4_mem_if.axi4_rd_addr_ch.arcache;
        sauria_axi4_mem_if.axi4_rd_addr_ch.arqos;
        sauria_axi4_mem_if.axi4_rd_addr_ch.arregion;
        */
    endtask

    virtual task set_rd_data();
           
        sauria_axi4_mem_if.axi4_rd_data_ch.rvalid <= 1'b1;
        sauria_axi4_mem_if.axi4_rd_data_ch.rresp  <= sauria_axi_resp_t'('h0);            
        sauria_axi4_mem_if.axi4_rd_data_ch.rlast  <= 1'b0;

        for(int chunk_id=0; chunk_id <= act_arlen; chunk_id++)begin
           
            wait (sauria_axi4_mem_if.axi4_rd_data_ch.rready);
            //fill_read_data();
            sauria_axi4_mem_if.axi4_rd_data_ch.rdata <= rd_data_item.rdata;

            if (chunk_id == act_arlen)
                sauria_axi4_mem_if.axi4_rd_data_ch.rlast <= 1'b1;
            
            @ (posedge sauria_ss_if.i_system_clk);
        end
        
        sauria_axi4_mem_if.axi4_rd_data_ch.rvalid <= 1'b0;
        sauria_axi4_mem_if.axi4_rd_data_ch.rlast  <= 1'b0;
        
    endtask

    virtual function void set_exp_arlen();
        case(tensor_item.tensor_type)
            IFMAPS: begin
                exp_arlen = tensor_item.ifmaps_elems.size()   / DATA_AXI_DATA_WIDTH;
            end
            WEIGHTS: begin
                exp_arlen =  tensor_item.weights_elems.size() / DATA_AXI_DATA_WIDTH;
            end
            PSUMS: begin
                exp_arlen = tensor_item.psums_elems.size() / DATA_AXI_DATA_WIDTH;
            end
        endcase
    endfunction

    virtual function void set_exp_arsize();
        exp_arsize = DATA_AXI_DATA_WIDTH;
    endfunction

    virtual function void fill_read_data();
        int last_data_idx;
        int elem_start_idx;

        case(tensor_item.tensor_type)
            IFMAPS: begin   
                last_data_idx = tensor_item.ifmaps_elems.size()*($bits(sauria_ifmaps_elem_data_t)/8) < $clog2(exp_arsize)  ? $clog2(exp_arsize) : tensor_item.ifmaps_elems.size();
                for(int data_idx=0; data_idx < last_data_idx; data_idx++)begin
                    elem_start_idx = data_idx*$bits(sauria_ifmaps_elem_data_t);
                    rd_data_item.rdata[elem_start_idx +: $bits(sauria_ifmaps_elem_data_t)] = tensor_item.ifmaps_elems[data_idx];
                end
            end
            WEIGHTS: begin
                last_data_idx = tensor_item.weights_elems.size()*($bits(sauria_weights_elem_data_t)/8) < $clog2(exp_arsize)  ? $clog2(exp_arsize) : tensor_item.weights_elems.size();
                for(int data_idx=0; data_idx < last_data_idx; data_idx++)begin
                    elem_start_idx = data_idx*$bits(sauria_weights_elem_data_t);
                    rd_data_item.rdata[elem_start_idx +: $bits(sauria_weights_elem_data_t)] = tensor_item.weights_elems[data_idx];
                end
            end
            PSUMS: begin
                last_data_idx = tensor_item.psums_elems.size()*($bits(sauria_psums_elem_data_t)/8) < $clog2(exp_arsize)  ? $clog2(exp_arsize) : tensor_item.psums_elems.size();
                for(int data_idx=0; data_idx < last_data_idx; data_idx++)begin
                    elem_start_idx = data_idx*$bits(sauria_weights_elem_data_t);
                    rd_data_item.rdata[elem_start_idx +: $bits(sauria_weights_elem_data_t)] = tensor_item.weights_elems[data_idx];
                end
            end
        endcase
        
    endfunction

    virtual task receive_axi4_mem_wr_req();

        fork 
            send_wr_addr();
            send_wr_data();
            get_wr_rsp(); 
        join

        case(wr_rsp_item.bresp)
            SLVERR: `sauria_error(message_id, "The slave successfully received the transaction address and data, but it encountered an error when attempting to perform the write operation")
            DECERR: `sauria_error(message_id, "The address was not mapped to any peripheral (slave)")
        endcase

    endtask

    virtual task send_wr_addr();
       
        @ (posedge sauria_ss_if.i_system_clk);
        sauria_axi4_mem_if.axi4_wr_addr_ch.awready <= 1'b1;
        wait(sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid);
        wr_addr_item.awaddr <= sauria_axi4_mem_if.axi4_wr_addr_ch.awaddr;
            
        wr_addr_item.awlen    <= sauria_axi4_mem_if.axi4_wr_addr_ch.awlen;
        wr_addr_item.awsize   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awsize;
        
        wr_addr_item.awprot   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awprot;    
        wr_addr_item.awlock   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awlock;      
        wr_addr_item.awcache  <= sauria_axi4_mem_if.axi4_wr_addr_ch.awcache;     
        wr_addr_item.awqos    <= sauria_axi4_mem_if.axi4_wr_addr_ch.awqos;     
        wr_addr_item.awregion <= sauria_axi4_mem_if.axi4_wr_addr_ch.awregion;     
        wait(!sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid);  
        sauria_axi4_mem_if.axi4_wr_addr_ch.awready <= 1'b0;
    endtask

    virtual task send_wr_data();
        
        @ (posedge sauria_ss_if.i_system_clk);
        sauria_axi4_mem_if.axi4_wr_data_ch.wready <= 1'b1;
        wait(sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
        wr_data_item.wdata <= sauria_axi4_mem_if.axi4_wr_data_ch.wdata;
        wr_data_item.wstrb <= sauria_axi4_mem_if.axi4_wr_data_ch.wstrb;
        wait(!sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
        sauria_axi4_mem_if.axi4_wr_data_ch.wready <= 1'b0;
    endtask

    virtual task get_wr_rsp();
        
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b0;
        @ (posedge sauria_ss_if.i_system_clk);
        wait(sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
     
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b1;
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bresp  <= 2'b0;
        wait(sauria_axi4_mem_if.axi4_wr_rsp_ch.bready);
        
        wait(!sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b0;
    endtask
    
endclass