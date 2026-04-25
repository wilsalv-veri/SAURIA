    assign sauria_ifmaps_feeder_if.clk           = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_clk;       
    assign sauria_ifmaps_feeder_if.srama_select  = sauria_ss.sauria_core_i.sauria_logic_top_i.o_sram_select[0];
    assign sauria_ifmaps_feeder_if.srama_data    = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_srama_data;       

    assign sauria_ifmaps_feeder_if.start         = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_start;    
    assign sauria_ifmaps_feeder_if.feeder_en     = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_feeder_en;    
    assign sauria_ifmaps_feeder_if.feeder_clear  = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_feeder_clear;
    assign sauria_ifmaps_feeder_if.act_valid     = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_act_valid; 
   
    assign sauria_ifmaps_feeder_if.clearfifo     = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_clearfifo;      
    assign sauria_ifmaps_feeder_if.pipeline_en   = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_pipeline_en;   
    assign sauria_ifmaps_feeder_if.pop_en        = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_pop_en;         

    assign sauria_ifmaps_feeder_if.done          = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_done; 	        
    assign sauria_ifmaps_feeder_if.til_done      = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_til_done; 	    
    assign sauria_ifmaps_feeder_if.srama_addr    = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_srama_addr;      
    assign sauria_ifmaps_feeder_if.srama_rden    = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_srama_rden;      
	assign sauria_ifmaps_feeder_if.fifo_empty    = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_fifo_empty; 	   
    assign sauria_ifmaps_feeder_if.fifo_full     = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_fifo_full; 	  
    assign sauria_ifmaps_feeder_if.feeder_stall  = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_feeder_stall;     

    assign sauria_ifmaps_feeder_if.act_deadlock  = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_act_deadlock;     
	assign sauria_ifmaps_feeder_if.a_arr         = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.o_a_arr;            

    assign sauria_ifmaps_feeder_if.data_valid    = sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_pop_en &
                                                   sauria_ss.sauria_core_i.sauria_logic_top_i.ifmap_feeder_i.i_pipeline_en;
