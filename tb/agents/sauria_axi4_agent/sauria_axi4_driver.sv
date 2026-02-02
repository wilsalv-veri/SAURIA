class sauria_axi4_driver extends uvm_driver #(sauria_tensor_mem_seq_item);

    `uvm_component_utils(sauria_axi4_driver)

    string message_id  = "SAURIA_AXI4_DRIVER";
    
    virtual sauria_axi4_ifc      sauria_axi4_mem_if;
    virtual sauria_subsystem_ifc sauria_ss_if;

    sauria_data_generator        data_generator;
    sauria_tensor_mem_seq_item   tensor_item;

    sauria_axi4_wr_txn_seq_item  wr_txn_item;
    sauria_axi4_rd_txn_seq_item  rd_txn_item;

    sauria_computation_params   computation_params;

    function new(string name="sauria_axi4_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        data_generator = sauria_data_generator::type_id::create("sauria_data_generator");
        tensor_item    = sauria_tensor_mem_seq_item::type_id::create("sauria_tensor_mem_seq_item");
        wr_txn_item    = sauria_axi4_wr_txn_seq_item::type_id::create("sauria_axi4_wr_txn_seq_item");
        rd_txn_item    = sauria_axi4_rd_txn_seq_item::type_id::create("sauria_axi4_rd_txn_seq_item");

       
        if (!uvm_config_db #(virtual sauria_axi4_ifc)::get(this, "", "sauria_axi4_mem_if", sauria_axi4_mem_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")
 
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        configure_generator();

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
        get_rd_addr();
        set_rd_data();  
    endtask

    virtual task wait_arvalid();
        sauria_axi4_mem_if.axi4_rd_addr_ch.arready <= 1'b1;
        @ (posedge sauria_axi4_mem_if.axi4_rd_addr_ch.arvalid);
    endtask

    virtual task get_rd_addr();
                
        sauria_axi4_mem_if.axi4_rd_addr_ch.arready <= 1'b0;
        rd_txn_item.rd_addr_item.arlen  <= sauria_axi4_mem_if.axi4_rd_addr_ch.arlen;
        rd_txn_item.rd_addr_item.arsize <= sauria_axi4_mem_if.axi4_rd_addr_ch.arsize;
        gen_data();
        
        /*The following fields are ignored for read requests
            sauria_axi4_mem_if.axi4_rd_addr_ch.arprot;
            sauria_axi4_mem_if.axi4_rd_addr_ch.arlock;
            sauria_axi4_mem_if.axi4_rd_addr_ch.arcache;
            sauria_axi4_mem_if.axi4_rd_addr_ch.arqos;
            sauria_axi4_mem_if.axi4_rd_addr_ch.arregion;
        */
    endtask

    virtual function void configure_generator();
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation_params")
 
        data_generator.configure_generator(tensor_item, rd_txn_item, computation_params);
    endfunction

    virtual function void gen_data();
        data_generator.set_tensor_type(sauria_axi4_mem_if.axi4_rd_addr_ch.araddr);
        data_generator.gen_read_data();
    endfunction


    virtual task set_rd_data();
           
        @ (posedge sauria_ss_if.i_system_clk);
         
        for(int chunk_id=0; chunk_id <= rd_txn_item.rd_addr_item.arlen; chunk_id++)begin
            
            sauria_axi4_mem_if.axi4_rd_data_ch.rvalid <= 1'b1;
            sauria_axi4_mem_if.axi4_rd_data_ch.rresp  <= sauria_axi_resp_t'('h0);            
            sauria_axi4_mem_if.axi4_rd_data_ch.rdata  <= rd_txn_item.rd_data_item.rdata;
            sauria_axi4_mem_if.axi4_rd_data_ch.rlast  <= chunk_id == rd_txn_item.rd_addr_item.arlen;
            wait (sauria_axi4_mem_if.axi4_rd_data_ch.rready);
            
            @ (posedge sauria_ss_if.i_system_clk);
            sauria_axi4_mem_if.axi4_rd_data_ch.rvalid <= 1'b0;
            @ (posedge sauria_ss_if.i_system_clk);
             
        end
        
        sauria_axi4_mem_if.axi4_rd_data_ch.rlast  <= 1'b0;
    endtask

    virtual task receive_axi4_mem_wr_req();

        fork 
            get_wr_addr();
            
            begin
                fork 
                    get_wr_data();
                    send_wr_rsp();
                join
            end 
        join

    endtask

    virtual task get_wr_addr();
       
        @ (posedge sauria_ss_if.i_system_clk);
        sauria_axi4_mem_if.axi4_wr_addr_ch.awready <= 1'b1;
        wait(sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid);
        wr_txn_item.wr_addr_item.awaddr   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awaddr;
            
        wr_txn_item.wr_addr_item.awlen    <= sauria_axi4_mem_if.axi4_wr_addr_ch.awlen;
        wr_txn_item.wr_addr_item.awsize   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awsize;
        
        wr_txn_item.wr_addr_item.awprot   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awprot;    
        wr_txn_item.wr_addr_item.awlock   <= sauria_axi4_mem_if.axi4_wr_addr_ch.awlock;      
        wr_txn_item.wr_addr_item.awcache  <= sauria_axi4_mem_if.axi4_wr_addr_ch.awcache;     
        wr_txn_item.wr_addr_item.awqos    <= sauria_axi4_mem_if.axi4_wr_addr_ch.awqos;     
        wr_txn_item.wr_addr_item.awregion <= sauria_axi4_mem_if.axi4_wr_addr_ch.awregion;     
        wait(!sauria_axi4_mem_if.axi4_wr_addr_ch.awvalid);  
        sauria_axi4_mem_if.axi4_wr_addr_ch.awready <= 1'b0;
    endtask

    virtual task get_wr_data();
        @ (posedge sauria_ss_if.i_system_clk);
        
        for(int chunk_id=0; chunk_id <= wr_txn_item.wr_addr_item.awlen; chunk_id++)begin
            sauria_axi4_mem_if.axi4_wr_data_ch.wready <= 1'b1;
            wait(sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
            wr_txn_item.wr_data_item.wdata <= sauria_axi4_mem_if.axi4_wr_data_ch.wdata;
            wr_txn_item.wr_data_item.wstrb <= sauria_axi4_mem_if.axi4_wr_data_ch.wstrb;
            wait(!sauria_axi4_mem_if.axi4_wr_data_ch.wvalid);
            sauria_axi4_mem_if.axi4_wr_data_ch.wready <= 1'b0;
            @ (posedge sauria_ss_if.i_system_clk);
        end
        
    endtask

    virtual task send_wr_rsp();
        
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b0;
        @ (posedge sauria_ss_if.i_system_clk);
        wait(sauria_axi4_mem_if.axi4_wr_data_ch.wvalid && sauria_axi4_mem_if.axi4_wr_data_ch.wlast);
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b1;
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bresp  <= 2'b0;
        wait(sauria_axi4_mem_if.axi4_wr_rsp_ch.bready);
        @ (posedge sauria_ss_if.i_system_clk);
        sauria_axi4_mem_if.axi4_wr_rsp_ch.bvalid <= 1'b0;
    endtask
    
endclass