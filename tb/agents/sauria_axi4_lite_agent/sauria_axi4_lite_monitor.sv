class sauria_axi4_lite_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_axi4_lite_monitor)

    string message_id = "SAURIA_AXI4_LITE_MONITOR";

    sauria_axi4_lite_wr_txn_seq_item cfg_wr_txn_item;
    sauria_axi4_lite_rd_txn_seq_item cfg_rd_txn_item;
    
    uvm_analysis_port #(sauria_axi4_lite_rd_txn_seq_item) send_cfg_perf_info;

    virtual sauria_axi4_lite_ifc  sauria_axi4_lite_cfg_if;
    virtual sauria_subsystem_ifc  sauria_ss_if;

    function new(string name="sauria_axi4_lite_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction


    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        cfg_wr_txn_item = sauria_axi4_lite_wr_txn_seq_item::type_id::create("sauria_axi4_lite_wr_txn_seq_item");
        cfg_rd_txn_item = sauria_axi4_lite_rd_txn_seq_item::type_id::create("sauria_axi4_lite_rd_txn_seq_item");
    
        send_cfg_perf_info = new("PERF_CFG_INFO_ANALYSIS_PORT", this);

        if (!uvm_config_db #(virtual sauria_axi4_lite_ifc)::get(this, "", "sauria_axi4_lite_cfg_if", sauria_axi4_lite_cfg_if))
            `sauria_error(message_id, "Failed to get access to axi4_lite_cfg_if")

        if (!uvm_config_db #(virtual sauria_subsystem_ifc)::get(this, "", "sauria_ss_if", sauria_ss_if))
            `sauria_error(message_id, "Failed to get access to sauria_ss_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            collect_cfg_rd_data();
        join
        
    endtask

    virtual task collect_cfg_rd_data();
        forever @ (posedge sauria_ss_if.i_system_clk) begin
            if (sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.arvalid)
               cfg_rd_txn_item.rd_addr_item.araddr =  sauria_axi4_lite_cfg_if.axi4_lite_rd_addr_ch.araddr; 
        
            if (sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rvalid) begin
                cfg_rd_txn_item.rd_data_item.rdata  = sauria_axi4_lite_cfg_if.axi4_lite_rd_data_ch.rdata;
                send_cfg_perf_info.write(cfg_rd_txn_item);
            end
        end

    endtask

endclass