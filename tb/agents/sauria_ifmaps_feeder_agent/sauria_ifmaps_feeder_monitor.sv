class sauria_ifmaps_feeder_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_ifmaps_feeder_monitor)

    parameter RD_LAT = 2;
    parameter POP_LAT_FIRST_CNTX = 2;
    parameter POP_LAT = 1;

    virtual sauria_ifmaps_feeder_ifc sauria_ifmaps_feeder_if;
    sauria_ifmaps_feeder_seq_item ifmaps_feeder_info; 

    uvm_analysis_port #(sauria_ifmaps_feeder_seq_item) send_ifmaps_feeder_info;
    uvm_analysis_port #(sauria_ifmaps_feeder_seq_item) send_ifmaps_feeder_srama_access_info;
    uvm_analysis_port #(sauria_ifmaps_feeder_seq_item) send_ifmaps_feeder_arr_info;

    string message_id = "SAURIA_IFMAPS_FEEDER_MONITOR";

    logic [sauria_pkg::ADRA_W-1:0] srama_addr_d = {sauria_pkg::ADRA_W{1'bx}};
    logic [sauria_pkg::ADRA_W-1:0] srama_addr_q;
    logic til_done_d, til_done_q;

    bit lat_wait = 1'b1;
    bit act_valid;
    int pop_done_count = 0;
    int pop_lat;

    function new(string name="sauria_ifmaps_feeder_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        send_ifmaps_feeder_info              = new("SAURIA_IFMAPS_FEEDER_ANALYSIS_PORT", this);
        send_ifmaps_feeder_srama_access_info = new("SAURIA_IFMAPS_FEEDER_SRAMA_ACCESS_INFO_ANALYSIS_PORT", this);
        send_ifmaps_feeder_arr_info          = new("SAURIA_IFMAPS_FEEDER_ARR_INFO_ANALYSIS_PORT", this);

        ifmaps_feeder_info = sauria_ifmaps_feeder_seq_item::type_id::create("sauria_ifmaps_feeder_seq_item", this);

        if (!uvm_config_db #(virtual sauria_ifmaps_feeder_ifc)::get (this, "", "sauria_ifmaps_feeder_if", sauria_ifmaps_feeder_if))
            `sauria_error(message_id, "Failed to get access to sauria_ifmaps_feeder_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        fork 
            get_ifmaps_feeder_info();
            get_ifmaps_feeder_srama_access_info();
            get_ifmaps_feeder_arr_info();
            set_pop_latency_wait();
            set_pop_lat();
        join
    endtask

    virtual task get_ifmaps_feeder_info();

        forever @ (posedge sauria_ifmaps_feeder_if.clk)begin

            ifmaps_feeder_info.clearfifo    = sauria_ifmaps_feeder_if.clearfifo;  
            ifmaps_feeder_info.feeder_clear = sauria_ifmaps_feeder_if.feeder_clear;  
            
            ifmaps_feeder_info.pipeline_en  = sauria_ifmaps_feeder_if.pipeline_en;
            ifmaps_feeder_info.pop_en       = sauria_ifmaps_feeder_if.pop_en; 

            ifmaps_feeder_info.done         =  sauria_ifmaps_feeder_if.done; 	        
            ifmaps_feeder_info.til_done     =  sauria_ifmaps_feeder_if.til_done; 	    
            ifmaps_feeder_info.fifo_empty   =  sauria_ifmaps_feeder_if.fifo_empty; 	
            ifmaps_feeder_info.fifo_full    =  sauria_ifmaps_feeder_if.fifo_full; 	
            ifmaps_feeder_info.feeder_stall =  sauria_ifmaps_feeder_if.feeder_stall;   
            ifmaps_feeder_info.act_deadlock =  sauria_ifmaps_feeder_if.act_deadlock;    
	        ifmaps_feeder_info.a_arr        =  sauria_ifmaps_feeder_if.a_arr;   
            send_ifmaps_feeder_info.write(ifmaps_feeder_info);     
        end
    endtask

    virtual task get_ifmaps_feeder_srama_access_info();
        
        forever @(posedge sauria_ifmaps_feeder_if.clk)begin
            
            if (sauria_ifmaps_feeder_if.feeder_clear) begin
                srama_addr_d  <= {sauria_pkg::ADRA_W{1'bx}};
                srama_addr_q <= {sauria_pkg::ADRA_W{1'bx}};
            end
            
            act_valid   <= sauria_ifmaps_feeder_if.act_valid;

            til_done_d <= sauria_ifmaps_feeder_if.til_done;
            til_done_q <= til_done_d;
                
            if ( 
                ((sauria_ifmaps_feeder_if.srama_rden && 
                srama_addr_d !== sauria_ifmaps_feeder_if.srama_addr) ) &&
                sauria_ifmaps_feeder_if.feeder_en) begin
                
                srama_addr_d <= sauria_ifmaps_feeder_if.srama_addr;
                srama_addr_q <= srama_addr_d;
                
                if (act_valid)begin
                    ifmaps_feeder_info.til_done     =  til_done_q;
                    ifmaps_feeder_info.srama_addr   =  srama_addr_q;   
                    ifmaps_feeder_info.srama_data   =  sauria_ifmaps_feeder_if.srama_data;     
                    send_ifmaps_feeder_srama_access_info.write(ifmaps_feeder_info);
                end
            end
        end
            
    endtask

    virtual task get_ifmaps_feeder_arr_info();
        forever @ (posedge sauria_ifmaps_feeder_if.clk)begin

            if(sauria_ifmaps_feeder_if.pipeline_en && 
            (sauria_ifmaps_feeder_if.pop_en || pop_done_count > 0))begin
                
                if(lat_wait)begin
                    repeat(pop_lat - 1) @ (posedge sauria_ifmaps_feeder_if.clk);
                    lat_wait <= 1'b0;
                end
                else begin
                    ifmaps_feeder_info.pop_en = pop_done_count != sauria_pkg::Y;
                    ifmaps_feeder_info.a_arr = sauria_ifmaps_feeder_if.a_arr;
                    send_ifmaps_feeder_arr_info.write(ifmaps_feeder_info);
                end
            end
        end
    endtask

    virtual task set_pop_latency_wait();
        forever @ (negedge sauria_ifmaps_feeder_if.pop_en)begin

            //Allow Last Row to Be Fed
            repeat(sauria_pkg::Y) begin
                wait(sauria_ifmaps_feeder_if.pipeline_en);
                pop_done_count <= pop_done_count + 1;
                @(posedge sauria_ifmaps_feeder_if.clk);
            end
            pop_done_count <= 0;
            lat_wait       <= 1'b1;
        end
    endtask

    virtual task set_pop_lat();
        forever @ (posedge sauria_ifmaps_feeder_if.clk)begin

            @(negedge sauria_ifmaps_feeder_if.feeder_clear);
            pop_lat = POP_LAT_FIRST_CNTX;
            wait(!lat_wait);
            pop_lat = POP_LAT;
        end
    endtask

endclass