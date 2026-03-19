class sauria_weights_feeder_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_weights_feeder_scbd)

    sauria_weights_feeder_seq_item weights_feeder_item;

    `uvm_analysis_imp_decl(_weights_feeder_info)
    uvm_analysis_imp_weights_feeder_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_info;

    `uvm_analysis_imp_decl (_weights_feeder_sramb_access_info)
    uvm_analysis_imp_weights_feeder_sramb_access_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_sramb_access_info;

    `uvm_analysis_imp_decl (_weights_feeder_arr_info)
    uvm_analysis_imp_weights_feeder_arr_info #(sauria_weights_feeder_seq_item, sauria_weights_feeder_scbd) receive_weights_feeder_arr_info;
    
    string message_id = "SAURIA_WEIGHTS_FEEDER_SCBD";
    
    sramb_addr_t               exp_next_sramb_addr;   
    weights_feeder_data_t      feeder_data[$];
    weights_feeder_data_t      feeder_data_inst;

    function new(string name="sauria_weights_feeder_scbd", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        receive_weights_feeder_info              = new("SAURIA_WEIGHTS_FEEDER_ANALYSIS_IMP", this);
        receive_weights_feeder_sramb_access_info = new("SAURIA_WEIGHTS_FEEDEER_SRAMB_ACCESS_INFO", this);
        receive_weights_feeder_arr_info          = new("SAURIA_WEIGHTS_FEEDER_ARR_INFO_ANALYSIS_IMP", this);
    endfunction

    
    function write_weights_feeder_info(sauria_weights_feeder_seq_item weights_feeder_info);
        weights_feeder_item = weights_feeder_info;

        if (weights_feeder_info.feeder_clear && weights_feeder_info.clearfifo) begin
            feeder_data.delete();
            exp_next_sramb_addr = sramb_addr_t'(0);
        end
    endfunction

    function write_weights_feeder_sramb_access_info(sauria_weights_feeder_seq_item weights_feeder_sramb_access_info);
        feeder_data_inst.sramb_addr = weights_feeder_sramb_access_info.sramb_addr;
        feeder_data_inst.sramb_data = weights_feeder_sramb_access_info.sramb_data;
        
        check_sramb_rd_addr();
        update_exp_sramb_rd_addr(weights_feeder_sramb_access_info.til_done);
        feeder_data.push_back(feeder_data_inst);

        //FIXME
        `sauria_info(message_id, $sformatf("Got SRAMB Access Addr: 0x%0h Data: 0x%0h Q_Size: %0d",
        feeder_data_inst.sramb_addr ,feeder_data_inst.sramb_data, feeder_data.size()))
        
    endfunction 

    function write_weights_feeder_arr_info(sauria_weights_feeder_seq_item weights_feeder_arr_info);
        
        if (feeder_data.size() > 0)begin
            update_feeder_data(weights_feeder_arr_info.b_arr);
            if ($countones(feeder_data[0].arr_byte_valid) == sauria_pkg::X) begin
                feeder_data[0].b_arr = get_reversed_array_bus(feeder_data[0].b_arr);
                if (feeder_data[0].sramb_data != feeder_data[0].b_arr) 
                    `sauria_error(message_id, $sformatf("Feeder Output Does Not Match SRAMB Read Data Q_Size: %0d Addr: 0x%0h Exp: 0x%0h Act: 0x%0h",
                    feeder_data.size(), feeder_data[0].sramb_addr ,feeder_data[0].sramb_data, feeder_data[0].b_arr ))
                else
                    `sauria_info(message_id, "Popped feeder data")
                feeder_data.pop_front();
                
            end
            
            if(!weights_feeder_arr_info.pop_en) clear_arr_byte_valids();
            
        end
        else `sauria_error(message_id, "WEIGHTS Feeder Fed Data Without Reading From SRAMA")
        
    endfunction

    virtual function void update_feeder_data(b_arr_data_t b_arr);
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::X) ? feeder_data.size() : sauria_pkg::X;
        
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::X; row++)begin
                //Find first invalid element
                if(!feeder_data[i].arr_byte_valid[row]) begin
                    feeder_data[i].arr_byte_valid[row] = 1'b1; //Set To Valid
                    feeder_data[i].b_arr[row]          = b_arr[row];
                    
                    if (i == 0) last_valid_queue_elem  = row + 1;
                    //FIXME
                    //`sauria_info(message_id, $sformatf("Valid b_arr_row[%0d]: 0x%0h Entry_Val: 0x%0h",
                    //row, b_arr[row], b_arr))
                    break;    
                end
            end
            
        end
    endfunction

     virtual function void check_sramb_rd_addr();
        if (exp_next_sramb_addr != feeder_data_inst.sramb_addr)
            `sauria_error(message_id, $sformatf("SRAMB_ADDR Mismatch Exp: 0x%0h Act: 0x%0h",  
        exp_next_sramb_addr, feeder_data_inst.sramb_addr))
    endfunction

    virtual function void update_exp_sramb_rd_addr(bit til_done);
        if (til_done) exp_next_sramb_addr = sramb_addr_t'(0);
        else exp_next_sramb_addr++;
    endfunction
   

    virtual function void clear_arr_byte_valids();
        int last_valid_queue_elem = (feeder_data.size() < sauria_pkg::X) ? feeder_data.size() : sauria_pkg::X;
        for(int i=0; i < last_valid_queue_elem; i++)begin 
            for(int row=0; row < sauria_pkg::X; row++)begin
                feeder_data[i].arr_byte_valid[row] = 1'b0;
            end
        end
    endfunction

    virtual function b_arr_data_t get_reversed_array_bus(b_arr_data_t b_arr);
        b_arr_data_t reversed_bus;
        for(int row=0; row < sauria_pkg::X; row++)begin
            reversed_bus[row] = b_arr[sauria_pkg::X - 1 - row];
        end
        return reversed_bus;
    endfunction


endclass

