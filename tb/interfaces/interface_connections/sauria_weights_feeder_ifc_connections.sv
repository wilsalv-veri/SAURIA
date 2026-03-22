assign sauria_weights_feeder_if.clk          = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_clk;
assign sauria_weights_feeder_if.rstn         = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_rstn;
	
assign sauria_weights_feeder_if.sramb_data   = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_sramb_data;

assign sauria_weights_feeder_if.feeder_en    = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_feeder_en;  
assign sauria_weights_feeder_if.feeder_clear = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_feeder_clear;   
assign sauria_weights_feeder_if.wei_valid    = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_wei_valid;   

assign sauria_weights_feeder_if.clearfifo     = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_clearfifo;      
assign sauria_weights_feeder_if.pipeline_en   = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_pipeline_en;   
assign sauria_weights_feeder_if.pop_en        = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_pop_en;         

assign sauria_weights_feeder_if.done   	     = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_done;    
assign sauria_weights_feeder_if.til_done 	 = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_til_done;   
assign sauria_weights_feeder_if.sramb_addr   = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_sramb_addr;  
assign sauria_weights_feeder_if.sramb_rden   = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_sramb_rden;  
assign sauria_weights_feeder_if.fifo_empty 	 = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_fifo_empty;  
assign sauria_weights_feeder_if.fifo_full 	 = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_fifo_full; 
assign sauria_weights_feeder_if.feeder_stall = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_feeder_stall;    

assign sauria_weights_feeder_if.wei_deadlock = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_wei_deadlock; 
assign sauria_weights_feeder_if.b_arr        = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.o_b_arr;    

assign sauria_weights_feeder_if.data_valid   = sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_pop_en &
                                              sauria_ss.sauria_core_i.sauria_logic_top_i.weight_feeder_i.i_pipeline_en;
