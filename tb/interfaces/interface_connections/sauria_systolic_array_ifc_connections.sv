assign sauria_systolic_array_if.clk         = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_clk;
assign sauria_systolic_array_if.rstn        = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_rstn;
assign sauria_systolic_array_if.a_arr       = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_a_arr;	        
assign sauria_systolic_array_if.b_arr       = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_b_arr;	        
assign sauria_systolic_array_if.i_c_arr     = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_c_arr;	        
assign sauria_systolic_array_if.reg_clear   = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_reg_clear;       
assign sauria_systolic_array_if.pipeline_en = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_pipeline_en;     
assign sauria_systolic_array_if.cswitch_arr = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_cswitch_arr;      
assign sauria_systolic_array_if.cscan_en    = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_cscan_en;         
assign sauria_systolic_array_if.thres       = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.i_thres;            
assign sauria_systolic_array_if.o_c_arr     = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.o_c_arr;            

for(genvar y=0; y < sauria_pkg::Y; y++)begin
    for(genvar x=0; x < sauria_pkg::X; x++)begin
        assign sauria_systolic_array_if.arr_psum_reserve_reg[y][x][sauria_pkg::OC_W-1:0] = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.y_axis[y].x_axis[x].sa_processing_element_i.mac_sc_q;
        assign sauria_systolic_array_if.arr_psum_accum[y][x][sauria_pkg::OC_W-1:0]       = sauria_ss.sauria_core_i.sauria_logic_top_i.sa_array_i.y_axis[y].x_axis[x].sa_processing_element_i.mac_q;
    
    end
end