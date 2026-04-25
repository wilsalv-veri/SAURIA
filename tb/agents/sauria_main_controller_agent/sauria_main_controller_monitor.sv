class sauria_main_controller_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_main_controller_monitor)

    string message_id = "SAURIA_MAIN_CONTROLLER_MONITOR";

    uvm_analysis_port #(sauria_main_controller_seq_item) send_main_controller_info;

    sauria_main_controller_seq_item main_controller_info;

    virtual sauria_main_controller_ifc sauria_main_controller_if;

    function new(string name="sauria_main_controller_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        
        main_controller_info = sauria_main_controller_seq_item::type_id::create("sauria_main_controller_seq_item");

        send_main_controller_info = new("SAURIA_MAIN_CONTROLLER_INFO_ANALYSIS_PORT", this);

        if (!uvm_config_db #(virtual sauria_main_controller_ifc)::get (this, "", "sauria_main_controller_if", sauria_main_controller_if))
            `sauria_error(message_id, "Failed to get access to sauria_main_controller_if")
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            get_main_controller_info();
        join
    endtask

    virtual task get_main_controller_info();
        
        forever @(posedge sauria_main_controller_if.clk)begin
            main_controller_info.act_feeder_en    = sauria_main_controller_if.act_feeder_en;       
            main_controller_info.act_feeder_clear = sauria_main_controller_if.act_feeder_clear; 
            main_controller_info.act_valid        = sauria_main_controller_if.act_valid;        
            main_controller_info.act_start        = sauria_main_controller_if.act_start;            
            main_controller_info.act_finalpush    = sauria_main_controller_if.act_finalpush;       
            main_controller_info.act_cnt_en       = sauria_main_controller_if.act_cnt_en;       
            main_controller_info.act_cnt_clear    = sauria_main_controller_if.act_cnt_clear;     
            main_controller_info.act_clearfifo    = sauria_main_controller_if.act_clearfifo;      
            main_controller_info.act_pop_en       = sauria_main_controller_if.act_pop_en;      
            main_controller_info.act_finalctx     = sauria_main_controller_if.act_finalctx;      
    
            main_controller_info.wei_feeder_en    = sauria_main_controller_if.wei_feeder_en;     
            main_controller_info.wei_feeder_clear = sauria_main_controller_if.wei_feeder_clear;       
            main_controller_info.wei_valid        = sauria_main_controller_if.wei_valid;            
            main_controller_info.wei_start        = sauria_main_controller_if.wei_start;            
            main_controller_info.wei_finalpush    = sauria_main_controller_if.wei_finalpush;       
            main_controller_info.wei_cnt_en       = sauria_main_controller_if.wei_cnt_en;         
            main_controller_info.wei_cnt_clear    = sauria_main_controller_if.wei_cnt_clear;     
            main_controller_info.wei_clearfifo    = sauria_main_controller_if.wei_clearfifo;   
            main_controller_info.wei_pop_en       = sauria_main_controller_if.wei_pop_en;       
            main_controller_info.wei_cswitch      = sauria_main_controller_if.wei_cswitch;       

	        main_controller_info.outbuf_start     = sauria_main_controller_if.outbuf_start;    
            main_controller_info.outbuf_reset     = sauria_main_controller_if.outbuf_reset;     

            main_controller_info.sa_clear         = sauria_main_controller_if.sa_clear;     
            main_controller_info.pipeline_en      = sauria_main_controller_if.pipeline_en;     
            main_controller_info.cswitch_arr      = sauria_main_controller_if.cswitch_arr;  

            main_controller_info.feed_deadlock    = sauria_main_controller_if.feed_deadlock; 
            main_controller_info.ctx_status       = sauria_main_controller_if.ctx_status;
            main_controller_info.feed_status      = sauria_main_controller_if.feed_status;
            main_controller_info.done             = sauria_main_controller_if.done;          

            send_main_controller_info.write(main_controller_info);
        end
    endtask 
endclass