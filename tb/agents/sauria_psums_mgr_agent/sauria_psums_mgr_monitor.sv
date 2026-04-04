class sauria_psums_mgr_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_psums_mgr_monitor)

    string message_id = "SAURIA_PSUMS_MGR_MONITOR";
    virtual sauria_psums_mgr_ifc sauria_psums_mgr_if;
    
    sauria_psums_mgr_seq_item psums_mgr_item;
    
    uvm_analysis_port #(sauria_psums_mgr_seq_item) send_psums_mgr_sramc_read_info;
    uvm_analysis_port #(sauria_psums_mgr_seq_item) send_psums_mgr_sramc_write_info;
    uvm_analysis_port #(sauria_psums_mgr_seq_item) send_psums_mgr_preload_vals_info;
    uvm_analysis_port #(sauria_psums_mgr_seq_item) send_psums_mgr_shift_reg_info;

    int curr_read_context_num,  next_read_context_num;
    int curr_write_context_num, next_write_context_num;

    function new(string name="sauria_psums_mgr_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        psums_mgr_item = sauria_psums_mgr_seq_item::type_id::create("sauria_psums_mgr_seq_item");
        send_psums_mgr_sramc_read_info   = new("SAURIA_PSUMS_MGR_SRAMC_READ_INFO_ANALYSIS_PORT", this);
        send_psums_mgr_sramc_write_info  = new("SAURIA_PSUMS_MGR_SRAMC_WRITE_INFO_ANALYSIS_PORT", this);
        send_psums_mgr_preload_vals_info = new("SAURIA_PSUMS_MGR_PRELOAD_VALS_INFO_ANALYSIS_PORT", this);
        send_psums_mgr_shift_reg_info    = new("SAURIA_PSUMS_MGR_SHIFT_REG_INFO_ANALYSIS_PORT", this);

        if (!uvm_config_db #(virtual sauria_psums_mgr_ifc)::get(this, "", "sauria_psums_mgr_if", sauria_psums_mgr_if))
            `sauria_error(message_id, "Failed to get access to sauria_psums_mgr_if")
        
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        
        fork 
            get_sramc_read_info();
            get_new_read_context();
            get_shift_reg_info();
            get_sramc_write_info();
            get_new_write_context();
            get_preload_values_info();
        join
    endtask

    virtual task get_sramc_read_info();
        forever @ (sauria_psums_mgr_if.sramc_read_cb)begin
            psums_mgr_item.context_num  = next_read_context_num;
            psums_mgr_item.sramc_addr   = sauria_psums_mgr_if.sramc_read_cb.sramc_addr;     
            psums_mgr_item.sramc_wmask  = sauria_psums_mgr_if.sramc_read_cb.sramc_wmask; 
            psums_mgr_item.sramc_rdata  = sauria_psums_mgr_if.sramc_rdata;
            send_psums_mgr_sramc_read_info.write(psums_mgr_item);  
        end
    endtask

    virtual task get_new_read_context();
        forever @ (sauria_psums_mgr_if.sramc_new_context_read_cb)begin
            next_read_context_num <= curr_read_context_num + 1;
            @ (posedge sauria_psums_mgr_if.clk);
            curr_read_context_num <= next_read_context_num;
        end
    endtask

    virtual task get_sramc_write_info();
        forever @ (sauria_psums_mgr_if.sramc_write_cb)begin
            psums_mgr_item.context_num  = next_write_context_num;
            psums_mgr_item.sramc_addr   = sauria_psums_mgr_if.sramc_addr;     
            psums_mgr_item.sramc_wmask  = sauria_psums_mgr_if.sramc_wmask; 
            psums_mgr_item.sramc_wdata  = sauria_psums_mgr_if.sramc_wdata;
            send_psums_mgr_sramc_write_info.write(psums_mgr_item);  
        end
    endtask
    
    virtual task get_new_write_context();
        forever @ (sauria_psums_mgr_if.sramc_new_context_write_cb)begin
            next_write_context_num <= curr_write_context_num + 1;
            @ (posedge sauria_psums_mgr_if.clk);
            curr_write_context_num <= next_write_context_num;    
        end
    endtask

    virtual task get_preload_values_info();
        forever @ (posedge sauria_psums_mgr_if.clk)begin
            if (sauria_psums_mgr_if.cscan_en == 1'b1)begin
                psums_mgr_item.cscan_en     = sauria_psums_mgr_if.cscan_en;     
                psums_mgr_item.i_c_arr      = sauria_psums_mgr_if.i_c_arr; 
                psums_mgr_item.o_c_arr      = sauria_psums_mgr_if.o_c_arr; 
                send_psums_mgr_preload_vals_info.write(psums_mgr_item);  
            end
        end
    endtask

    virtual task get_shift_reg_info();
        forever @ (negedge sauria_psums_mgr_if.shift_reg_shift)begin
            psums_mgr_item.shift_done = 1'b1;
            send_psums_mgr_shift_reg_info.write(psums_mgr_item);
        end
    endtask

endclass