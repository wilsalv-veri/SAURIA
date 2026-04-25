assign sauria_main_controller_if.clk              = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.i_clk;  
assign sauria_main_controller_if.rstn             = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.i_rstn;   

assign sauria_main_controller_if.act_feeder_en    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_feeder_en;  
assign sauria_main_controller_if.act_feeder_clear = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_feeder_clear;   
assign sauria_main_controller_if.act_valid        = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_valid;  
assign sauria_main_controller_if.act_start        = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_start;    
assign sauria_main_controller_if.act_finalpush    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_finalpush;      
assign sauria_main_controller_if.act_cnt_en       = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_cnt_en;   
assign sauria_main_controller_if.act_cnt_clear    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_cnt_clear;   
assign sauria_main_controller_if.act_clearfifo    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_clearfifo;    
assign sauria_main_controller_if.act_pop_en       = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_pop_en;
assign sauria_main_controller_if.act_finalctx     = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_act_finalctx;   
assign sauria_main_controller_if.wei_feeder_en    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_feeder_en;  
    
assign sauria_main_controller_if.wei_feeder_clear = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_feeder_clear;
assign sauria_main_controller_if.wei_valid        = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_valid; 
assign sauria_main_controller_if.wei_start        = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_start;   
assign sauria_main_controller_if.wei_finalpush    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_finalpush;  
assign sauria_main_controller_if.wei_cnt_en       = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_cnt_en;  
assign sauria_main_controller_if.wei_cnt_clear    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_cnt_clear;  
assign sauria_main_controller_if.wei_clearfifo    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_clearfifo;  
assign sauria_main_controller_if.wei_pop_en       = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_pop_en;       
assign sauria_main_controller_if.wei_cswitch      = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_wei_cswitch;

assign sauria_main_controller_if.outbuf_start     = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_outbuf_start;    
assign sauria_main_controller_if.outbuf_reset     = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_outbuf_reset;    

assign sauria_main_controller_if.sa_clear         = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_sa_clear;   
assign sauria_main_controller_if.pipeline_en      = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_pipeline_en;    
assign sauria_main_controller_if.cswitch_arr      = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_cswitch_arr;    

assign sauria_main_controller_if.feed_deadlock    = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_feed_deadlock;  
assign sauria_main_controller_if.ctx_status       = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_ctx_status;  
assign sauria_main_controller_if.feed_status      = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_feed_status;  
assign sauria_main_controller_if.done             = sauria_ss.sauria_core_i.sauria_logic_top_i.main_controller_i.o_done;     
