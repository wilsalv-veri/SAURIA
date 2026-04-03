class sauria_ifmaps_feeder_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_ifmaps_feeder_scbd)

    `uvm_analysis_imp_decl (_ifmaps_feeder_info)
    uvm_analysis_imp_ifmaps_feeder_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_info; 

    `uvm_analysis_imp_decl (_ifmaps_feeder_srama_access_info)
    uvm_analysis_imp_ifmaps_feeder_srama_access_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_srama_access_info;

    `uvm_analysis_imp_decl (_ifmaps_feeder_arr_info)
    uvm_analysis_imp_ifmaps_feeder_arr_info #(sauria_ifmaps_feeder_seq_item, sauria_ifmaps_feeder_scbd) receive_ifmaps_feeder_arr_info;
    
    sauria_ifmaps_feeder_seq_item ifmaps_feeder_item;

    srama_addr_t               exp_next_srama_addr;   
    ifmaps_feeder_data_t       feeder_data[$];
    ifmaps_feeder_data_t       feeder_data_inst;
    ifmaps_feeder_data_t       popped_inst;
    
    arr_col_data_t             ifmaps_rows_active;

    sauria_computation_params  computation_params;
    
   
    string message_id = "SAURIA_IFMAPS_FEEDER_SCBD";

    function new(string name="sauria_ifmaps_feeder_scbd", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_ifmaps_feeder_info              = new("SAURIA_IFMAPS_FEEDER_ANALYSIS_IMP", this);
        receive_ifmaps_feeder_srama_access_info = new("SAURIA_IFMAPS_FEEDEER_SRAMA_ACCESS_INFO", this);
        receive_ifmaps_feeder_arr_info          = new("SAURIA_IFMAPS_FEEDER_ARR_INFO_ANALYSIS_IMP", this);
    
        if (!uvm_config_db #(sauria_computation_params)::get(this, "", "computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
    
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);
        wait(computation_params.ifmaps_cfg_shared);
        ifmaps_rows_active         = computation_params.ifmaps_rows_active;
    endtask

    function write_ifmaps_feeder_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_info);
        ifmaps_feeder_item = ifmaps_feeder_info;

        if (ifmaps_feeder_info.feeder_clear && ifmaps_feeder_info.clearfifo) begin
            feeder_data.delete();
            exp_next_srama_addr = srama_addr_t'(0);
        end
    endfunction

    function write_ifmaps_feeder_srama_access_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_srama_access_info);
        feeder_data_inst.srama_addr = ifmaps_feeder_srama_access_info.srama_addr;
        feeder_data_inst.srama_data = ifmaps_feeder_srama_access_info.srama_data;
        
        `sauria_info(message_id, $sformatf("Got SRAMA Access Addr: 0x%0h Data: 0x%0h",
        ifmaps_feeder_srama_access_info.srama_addr ,ifmaps_feeder_srama_access_info.srama_data))
        
        //FIXME: wilsalv :Re-enable
        //check_srama_rd_addr();
        update_exp_srama_rd_addr(ifmaps_feeder_srama_access_info.til_done);
        feeder_data.push_back(feeder_data_inst);
    endfunction 

    function write_ifmaps_feeder_arr_info(sauria_ifmaps_feeder_seq_item ifmaps_feeder_arr_info);
        
        if (feeder_data.size() > 0)begin
            update_feeder_data(ifmaps_feeder_arr_info.a_arr);
            if ($countones(feeder_data[0].arr_byte_valid) == sauria_pkg::Y) begin
                feeder_data[0].a_arr      = get_reversed_array_bus(feeder_data[0].a_arr);
                feeder_data[0].srama_data = get_masked_inactive_rows_data(feeder_data[0].srama_data);

                if (feeder_data[0].srama_data != feeder_data[0].a_arr) 
                    `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMA Read Data Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    feeder_data[0].srama_addr ,feeder_data[0].srama_data, feeder_data[0].a_arr ))
                
                popped_inst = feeder_data.pop_front();
            end
            
            if(!ifmaps_feeder_arr_info.pop_en) clear_arr_byte_valids();
            
        end
        else `sauria_error(message_id, "IFMAPS Feeder Fed Data Without Reading From SRAMA")
        
    endfunction

    virtual function void update_feeder_data(a_arr_data_t a_arr);
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::Y) ? feeder_data.size() : sauria_pkg::Y;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::Y; row++)begin
                //Find first invalid element
                if(!feeder_data[i].arr_byte_valid[row]) begin
                    feeder_data[i].arr_byte_valid[row] = 1'b1; //Set To Valid
                    feeder_data[i].a_arr[row]          = a_arr[row];
                    
                    if (i == 0) last_valid_queue_elem  = row + 1;
                    
                    `sauria_info(message_id, $sformatf("Valid a_arr_row[%0d]: 0x%0h Entry_Val: 0x%0h",
                    row, a_arr[row], a_arr))
                    break;    
                end
            end
            
        end
    endfunction

    virtual function void check_srama_rd_addr();
        if (exp_next_srama_addr != feeder_data_inst.srama_addr)
            `sauria_error(message_id, $sformatf("SRAMA_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",  
        exp_next_srama_addr, feeder_data_inst.srama_addr))
    endfunction

    virtual function void update_exp_srama_rd_addr(bit til_done);
        if (til_done) exp_next_srama_addr = srama_addr_t'(0);
        else exp_next_srama_addr++;
    endfunction
    
    virtual function void clear_arr_byte_valids();
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::Y) ? feeder_data.size() : sauria_pkg::Y;
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::Y; row++)begin
                feeder_data[i].arr_byte_valid[row] = 1'b0;
            end
        end
    endfunction

    virtual function a_arr_data_t get_reversed_array_bus(a_arr_data_t a_arr);
        a_arr_data_t reversed_bus;
        for(int row=0; row < sauria_pkg::Y; row++)begin
            reversed_bus[row] = a_arr[sauria_pkg::Y - 1 - row];
        end
        return reversed_bus;
    endfunction

    virtual function a_arr_data_t get_masked_inactive_rows_data(a_arr_data_t a_arr);
        a_arr_data_t masked_row_data;
        arr_col_data_rev_t rev_ifmaps_rows_active  = ifmaps_rows_active;

        for(int row=0; row < sauria_pkg::Y; row++)begin
            masked_row_data[row] = (rev_ifmaps_rows_active[row] == 1'b1) ? a_arr[row] : 0;

            if (ifmaps_rows_active[row] == 1'b1) `sauria_info(message_id, $sformatf("IFMAPS_ROWS_ACTIVE ROW: %0d", row))
        end
        return masked_row_data;
    
    endfunction

endclass
