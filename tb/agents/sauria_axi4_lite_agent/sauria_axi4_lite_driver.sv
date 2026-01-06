class sauria_axi4_lite_driver extends uvm_driver #(sauria_axi_txn_base_seq_item);

    `uvm_component_utils(sauria_axi4_lite_driver)

    string message_id  = "SAURIA_AXI4_LITE_DRIVER";

    sauria_axi_txn_base_seq_item      axi4_lite_cfg_txn_item;
    virtual sauria_axi4_lite_ifc      sauria_axi4_lite_cfg_if;

    virtual sauria_subsystem_ifc       sauria_ss_if;

    sauria_axi4_lite_wr_rsp_seq_item  wr_rsp_item;
    sauria_axi4_lite_rd_data_seq_item rd_data_item;
    
    bit                               done_driving = 1'b0;

    function new(string name="sauria_axi4_lite_driver", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        axi4_lite_cfg_txn_item = sauria_axi_txn_base_seq_item::type_id::create("axi4_lite_base_seq_item");
        
        if (!uvm_config_db #(virtual sauria_axi4_lite_ifc)::get(this, "", "sauria_axi4_lite_cfg_if", sauria_axi4_lite_cfg_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        @ (posedge sauria_ss_if.i_system_rstn);

        forever begin
            seq_item_port.get_next_item(axi4_lite_cfg_txn_item);
            
            `sauria_info(message_id, "Received AXI4_LITE_CFG_TXN_ITEM")

            case(axi4_lite_cfg_txn_item.txn_type)
                RD_TXN : drive_axi4_lite_cfg_rd_txn();
                WR_TXN : drive_axi4_lite_cfg_wr_txn();
            endcase 
            
            seq_item_port.item_done();
            //done_driving = 1'b1;
        end
    endtask

    virtual task drive_axi4_lite_cfg_rd_txn();

    endtask
    
    virtual task drive_axi4_lite_cfg_wr_txn();

        sauria_axi4_lite_wr_txn_seq_item wr_txn_item;

        `sauria_info(message_id, "Driving AXI4_LITE_WR_TXN")

        if ($cast(wr_txn_item, axi4_lite_cfg_txn_item))begin
            sauria_axi4_lite_wr_addr_seq_item wr_addr_item = wr_txn_item.wr_addr_item;
            sauria_axi4_lite_wr_data_seq_item wr_data_item = wr_txn_item.wr_data_item;
                                              wr_rsp_item  = wr_txn_item.wr_rsp_item;

            fork 
                drive_wr_addr_ch(wr_addr_item);
                drive_wr_data_ch(wr_data_item);
                drive_wr_rsp_ch(wr_rsp_item);
            join

            case(wr_rsp_item.bresp)
                SLVERR: `sauria_error(message_id, "The slave successfully received the transaction address and data, but it encountered an error when attempting to perform the write operation")
                DECERR: `sauria_error(message_id, "The address was not mapped to any peripheral (slave)")
            endcase

        end
        else `sauria_error(message_id, $sformatf("Failed to cast axi4_lite_cfg_txn_item with txn_type: %s to sauria_axi4_lite_wr_txn_seq_item", axi4_lite_cfg_txn_item.txn_type))
    
    endtask

    virtual task drive_rd_addr_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_rd_addr_seq_item rd_addr_item;
        
        if ($cast(rd_addr_item, axi4_lite_item))begin
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.araddr  <= rd_addr_item.araddr;  
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arprot  <= rd_addr_item.arprot;   
           sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arvalid <= 1'b1;
            @ (posedge sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arready);
        end
        else `sauria_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_rd_addr_seq_item")
        
    endtask

    virtual task drive_rd_data_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        
        if ($cast(rd_data_item, axi4_lite_item))begin
            sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rready <=  1'b1;

            @(posedge sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid);
            rd_data_item.rvalid <= sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid; 
            rd_data_item.rdata <= sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rdata;
            rd_data_item.rresp <= sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rresp;            
        end
        else `sauria_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_rd_data_seq_item")

    endtask

    virtual task drive_wr_addr_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_wr_addr_seq_item wr_addr_item;
        
        `sauria_info(message_id, "Driving AXI4_LITE WR ADDRESS")


        if ($cast(wr_addr_item, axi4_lite_item))begin
            @ (posedge sauria_ss_if.i_system_clk);
            `sauria_info(message_id, "Driving AXI4_LITE WR ADDRESS")

            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awaddr  <=  wr_addr_item.awaddr;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awprot  <=  wr_addr_item.awprot;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awvalid <=  1'b1;
            wait (sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awready);
            `sauria_info(message_id, "Got AXI4_LITE AWREADY")
            @ (posedge sauria_ss_if.i_system_clk);
            sauria_axi4_lite_cfg_if.axi4_lite_wr_addr_ch.awvalid <=  1'b0;
           
        end
        else `sauria_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_addr_seq_item")

    endtask

    virtual task drive_wr_data_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        sauria_axi4_lite_wr_data_seq_item wr_data_item;
        
        `sauria_info(message_id, "Driving AXI4_LITE WR DATA")

        if ($cast(wr_data_item, axi4_lite_item)) begin
            @ (posedge sauria_ss_if.i_system_clk);
            `sauria_info(message_id, "Driving AXI4_LITE WR DATA")
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wdata  <= wr_data_item.wdata;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wstrb  <= wr_data_item.wstrb;
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wvalid <= 1'b1;
            wait (sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wready);
            `sauria_info(message_id, "Got AXI4_LITE WREADY")
            @ (posedge sauria_ss_if.i_system_clk);
            `sauria_info(message_id, "Next Clk")
            
            sauria_axi4_lite_cfg_if.axi4_lite_wr_data_ch.wvalid <= 1'b0;

        end
        else `sauria_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_data_seq_item")

    endtask

    virtual task drive_wr_rsp_ch(sauria_axi4_lite_base_seq_item axi4_lite_item);
        
        `sauria_info(message_id, "Driving AXI4_LITE WR RESPONSE")

        if ($cast(wr_rsp_item, axi4_lite_item))begin
            sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bready <= 1;

            wait(sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bvalid);
          
            wr_rsp_item.bresp  = sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bresp;
            wr_rsp_item.bvalid = sauria_axi4_lite_cfg_if.axi4_lite_wr_rsp_ch.bvalid;
            
        end
        else `sauria_error(message_id, "Failed to cast axi4_lite_base_item into axi4_lite_wr_rsp_seq_item")

    endtask

endclass