assign sauria_psums_mgr_if.clk          = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.i_clk;
assign sauria_psums_mgr_if.rstn         = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.i_rstn;

assign sauria_psums_mgr_if.cnt_en       = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.cnt_en;

assign sauria_psums_mgr_if.sramc_addr   = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_sramc_addr;
assign sauria_psums_mgr_if.sramc_wren   = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_sramc_wren;
assign sauria_psums_mgr_if.sramc_rden   = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_sramc_rden;
assign sauria_psums_mgr_if.sramc_wmask  = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_sramc_wmask;

assign sauria_psums_mgr_if.cscan_en     = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_cscan_en;
assign sauria_psums_mgr_if.sramc_rdata  = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.i_sramc_rdata;   
assign sauria_psums_mgr_if.sramc_wdata  = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_sramc_wdata;   
assign sauria_psums_mgr_if.i_c_arr      = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.i_c_arr;  
assign sauria_psums_mgr_if.o_c_arr      = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.o_c_arr;  

assign sauria_psums_mgr_if.shift_reg_shift  = sauria_ss.sauria_core_i.sauria_logic_top_i.psm_top_i.buff_shift_en;  
