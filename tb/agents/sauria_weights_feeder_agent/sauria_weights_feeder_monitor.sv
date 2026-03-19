class sauria_weights_feeder_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_weights_feeder_monitor)

    string message_id = "SAURIA_WEIGHTS_FEEDER_MONITOR";
    
    virtual sauria_weights_feeder_ifc sauria_weights_feeder_if;
    
    parameter RD_LAT = 2;
    parameter POP_LAT_FIRST_CNTX = 2;
    parameter POP_LAT = 1;

    sauria_weights_feeder_seq_item weights_feeder_info;

    uvm_analysis_port #(sauria_weights_feeder_seq_item) send_weights_feeder_info;
    uvm_analysis_port #(sauria_weights_feeder_seq_item) send_weights_feeder_sramb_access_info;
    uvm_analysis_port #(sauria_weights_feeder_seq_item) send_weights_feeder_arr_info;

    logic [sauria_pkg::ADRB_W-1:0] sramb_addr_d = {sauria_pkg::ADRB_W{1'bx}};
    logic [sauria_pkg::ADRB_W-1:0] sramb_addr_q;
    logic til_done_d, til_done_q;

    bit lat_wait = 1'b1;
    bit wei_valid;
    int pop_done_count = 0;
    int pop_lat;

    function new(string name="sauria_weights_feeder_monitor", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        weights_feeder_info = sauria_weights_feeder_seq_item::type_id::create("sauria_weights_feeder_seq_item", this);
        
        send_weights_feeder_info              = new("SAURIA_WEIGHTS_FEEDER_ANALYSIS_PORT", this);
        send_weights_feeder_sramb_access_info = new("SAURIA_WEIGHTS_FEEDER_SRAMB_ACCESS_INFO_ANALYSIS_PORT", this);
        send_weights_feeder_arr_info          = new("SAURIA_WEIGHTS_FEEDER_ARR_INFO_ANALYSIS_PORT", this);

        if(!uvm_config_db #(virtual sauria_weights_feeder_ifc)::get(this, "", "sauria_weights_feeder_if", sauria_weights_feeder_if))
            `sauria_error(message_id, "Failed to get access to sauria_weights_feeder_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            get_weights_feeder_info();
            get_weights_feeder_sramb_access_info();
            get_weights_feeder_arr_info();
            set_pop_latency_wait();
            set_pop_lat();
        join
    endtask

    virtual task get_weights_feeder_info();
        forever @ (posedge sauria_weights_feeder_if.clk)begin

            weights_feeder_info.clearfifo    = sauria_weights_feeder_if.clearfifo;  
            weights_feeder_info.feeder_clear = sauria_weights_feeder_if.feeder_clear;  
            
            weights_feeder_info.pipeline_en  = sauria_weights_feeder_if.pipeline_en;
            weights_feeder_info.pop_en       = sauria_weights_feeder_if.pop_en; 

            weights_feeder_info.sramb_data   = sauria_weights_feeder_if.sramb_data;     
            weights_feeder_info.feeder_en    = sauria_weights_feeder_if.feeder_en;     
            weights_feeder_info.wei_valid    = sauria_weights_feeder_if.wei_valid;       
            weights_feeder_info.done         = sauria_weights_feeder_if.done; 	      
            weights_feeder_info.til_done     = sauria_weights_feeder_if.til_done; 	    
            weights_feeder_info.sramb_addr   = sauria_weights_feeder_if.sramb_addr;   
            weights_feeder_info.sramb_rden   = sauria_weights_feeder_if.sramb_rden;   
	        weights_feeder_info.fifo_empty   = sauria_weights_feeder_if.fifo_empty; 	
            weights_feeder_info.fifo_full    = sauria_weights_feeder_if.fifo_full; 
            weights_feeder_info.feeder_stall = sauria_weights_feeder_if.feeder_stall;   
            weights_feeder_info.wei_deadlock = sauria_weights_feeder_if.wei_deadlock;    
	        weights_feeder_info.b_arr        = sauria_weights_feeder_if.b_arr;    
            send_weights_feeder_info.write(weights_feeder_info);
        end
    endtask

    //FIXME
    virtual task get_weights_feeder_sramb_access_info();
        
        forever @(posedge sauria_weights_feeder_if.clk)begin
            
            if (sauria_weights_feeder_if.feeder_clear) begin
                sramb_addr_d <= {sauria_pkg::ADRB_W{1'bx}};
                sramb_addr_q <=  {sauria_pkg::ADRB_W{1'bx}};
            end
            
            wei_valid      <= sauria_weights_feeder_if.wei_valid;
            
            til_done_d <= sauria_weights_feeder_if.til_done;
            til_done_q <= til_done_d;
                
            if ( 
                ((sauria_weights_feeder_if.sramb_rden && 
                sramb_addr_d !== sauria_weights_feeder_if.sramb_addr) ) &&
                sauria_weights_feeder_if.feeder_en) begin
                
                sramb_addr_d <= sauria_weights_feeder_if.sramb_addr;
                sramb_addr_q <= sramb_addr_d;
                
                if (wei_valid)begin
                weights_feeder_info.til_done     =  til_done_q;
                weights_feeder_info.sramb_addr   =  sramb_addr_q;   
                weights_feeder_info.sramb_data   =  sauria_weights_feeder_if.sramb_data;     
                send_weights_feeder_sramb_access_info.write(weights_feeder_info);
                end
            end
        end
            
    endtask

    virtual task get_weights_feeder_arr_info();
        forever @ (posedge sauria_weights_feeder_if.clk)begin

            if(sauria_weights_feeder_if.pipeline_en && 
            (sauria_weights_feeder_if.pop_en || pop_done_count > 0))begin
                
                if(lat_wait)begin
                    repeat(pop_lat - 1) @ (posedge sauria_weights_feeder_if.clk);
                    lat_wait <= 1'b0;
                end
                else begin
                    weights_feeder_info.pop_en = pop_done_count != sauria_pkg::X;
                    weights_feeder_info.b_arr = sauria_weights_feeder_if.b_arr;
                    send_weights_feeder_arr_info.write(weights_feeder_info);
                end
            end
        end
    endtask

    virtual task set_pop_latency_wait();
        forever @ (negedge sauria_weights_feeder_if.pop_en)begin

            //Allow Last Row to Be Fed
            repeat(sauria_pkg::X) begin
                pop_done_count <= pop_done_count + 1;
                @(posedge sauria_weights_feeder_if.clk);
            end
            pop_done_count <= 0;
            lat_wait       <= 1'b1;
        end
    endtask

    virtual task set_pop_lat();
        forever @ (posedge sauria_weights_feeder_if.clk)begin

            @(negedge sauria_weights_feeder_if.feeder_clear);
            pop_lat = POP_LAT_FIRST_CNTX;
            wait(!lat_wait);
            pop_lat = POP_LAT;
        end
    endtask

endclass