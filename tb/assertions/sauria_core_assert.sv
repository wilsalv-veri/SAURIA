import sauria_pkg::*;
import sauria_common_pkg::*;
import sauria_base_cfg_seqs_pkg::*;
import uvm_pkg::*;

module sauria_core_assert ( input logic i_clk,

                            //Main Controller
                            input logic mc_start,
                            input logic sa_pipeline_en,
                            input logic mc_finalwrite,
                            input logic [sauria_pkg::ACT_IDX_W-1:0] mc_incntlim,
                            input logic cg_done,

                            //IFMAPS Feeder
                            input logic af_act_clearfifo,
                            input logic af_act_cnt_clear,
                            input logic af_act_feeder_en,
                            input logic af_act_valid,
                            input logic af_act_start,
                            
                            input logic af_act_cnt_en,
                            input logic mc_act_stall,
                            input logic af_act_pop_en,
                            input logic mc_act_done,
                            input logic mc_act_til_done,
                            input logic [sauria_pkg::OUT_IDX_W-1:0] mc_act_reps,
                            input logic o_srama_rden,

                            //Weight Feeder
                            input logic wf_wei_clearfifo,
                            input logic wf_wei_cnt_clear,
                            input logic wf_wei_feeder_en,
                            input logic wf_wei_valid,
                            input logic wf_wei_start,
                            
                            input logic wf_wei_cnt_en,
                            input logic mc_wei_stall,
                            input logic wf_wei_pop_en,
                            input logic mc_wei_done,
                            input logic mc_wei_til_done,
                            input logic [sauria_pkg::OUT_IDX_W-1:0] mc_wei_reps,
                            input logic o_sramb_rden,

                            //PSUMS Manager
                            input logic ob_outbuf_start,
                            input logic [sauria_pkg::OUT_IDX_W-1:0] ob_ncontexts,
                            input logic ob_preload_en,
                            input logic sa_cscan_en,
                            input logic mc_shift_done,
                            input logic o_sramc_rden,
                            input logic o_sramc_wren,
                            input logic mc_outbuf_done
                            
                        );

    logic act_pop_en;
    logic act_feeder_active;

    logic wei_pop_en;
    logic wei_feeder_active;

    logic feeders_pop_en;
    
    logic [31:0] ctx_idx;
    
    logic [31:0] num_sramc_read;
    logic [31:0] num_sramc_write;

    assign act_pop_en        = sa_pipeline_en & af_act_feeder_en && af_act_valid && af_act_pop_en;
    assign act_feeder_active = sa_pipeline_en & af_act_feeder_en && af_act_valid;

    assign wei_pop_en        = sa_pipeline_en & wf_wei_feeder_en && wf_wei_valid && wf_wei_pop_en;
    assign wei_feeder_active = sa_pipeline_en & wf_wei_feeder_en && wf_wei_valid;

    assign feeders_pop_en    = act_pop_en && wei_pop_en;

    always_ff @(posedge i_clk) begin
        if ($rose(mc_start)) begin
            ctx_idx         <= '0;
            num_sramc_read  <= '0;
            num_sramc_write <= '0;
        end else if ($rose(o_sramc_rden)) begin
            num_sramc_read  <= num_sramc_read  + 1;
        end else if ($rose(o_sramc_wren)) begin
            num_sramc_write <= num_sramc_write + 1;
        end
        
        if (ob_outbuf_start)
            ctx_idx         <= '0;
        else if (feeders_pop_en)
            ctx_idx         <= ctx_idx + 1;
        
    end

    //Forward Progress Deadlock Detection  
    assert property (@ (posedge i_clk) $rose(mc_start)   |=> s_eventually $rose(cg_done) ) else `sauria_sva_error("Started Core Computation Never Finished");        
    
    assert property (@ (posedge i_clk) $rose(mc_start)   |-> ##2 !(af_act_clearfifo || af_act_cnt_clear) until $fell(af_act_valid)   ) else `sauria_sva_error("IFMAPS Feeder Cleared While Computation Active");        
    assert property (@ (posedge i_clk) $rose(cg_done)    |->   (af_act_clearfifo && af_act_cnt_clear) until $rose(mc_start)      ) else `sauria_sva_error("IFMAPS Feeder Not Cleared After Computation Finished");        
    assert property (@ (posedge i_clk) $rose(mc_start)   |-> ##3 $rose(af_act_start)        ) else `sauria_sva_error("IFMAPS Feeder Doesn't Start  After Core Started");        
    assert property (@ (posedge i_clk) $rose(mc_start)   |-> ##[1:50] act_pop_en              ) else `sauria_sva_error("IFMAPS Feeder Doesn't Feed Data After Core Started");        
    assert property (@ (posedge i_clk) $rose(act_pop_en) |-> s_eventually mc_act_done         ) else `sauria_sva_error("IFMAPS Feeder Doesn't Finish Context After Feeding");          
    assert property (@ (posedge i_clk) mc_act_done       |-> s_eventually mc_act_til_done     ) else `sauria_sva_error("IFMAPS Feeder Tile Doesn't Finish");          
    assert property (@ (posedge i_clk) act_pop_en        |-> ##[2:3] !mc_act_stall            ) else `sauria_sva_error("IFMAPS Feeder Stall And Feeding Indication Asserted Simultanously");
    assert property (@ (posedge i_clk) (act_feeder_active && !act_pop_en) |-> ##[1:3] mc_act_stall) else `sauria_sva_error("IFMAPS Feeder Doesn't Assert Stall When Not Feeding");

    assert property (@ (posedge i_clk) $rose(mc_start)    |-> ##2 !(wf_wei_clearfifo || wf_wei_cnt_clear) until $fell(wf_wei_valid)      ) else `sauria_sva_error("Weights Feeder Cleared While Computation Active");        
    assert property (@ (posedge i_clk) $rose(cg_done)     |->   (af_act_clearfifo && af_act_cnt_clear) until $rose(mc_start)      ) else `sauria_sva_error("IFMAPS Feeder Not Cleared After Computation Finished");        
    assert property (@ (posedge i_clk) $rose(mc_start)    |-> ##3 $rose(wf_wei_start)       ) else `sauria_sva_error("Weights Feeder Doesn't Start  After Core Started");        
    assert property (@ (posedge i_clk) $rose(mc_start)    |-> ##[1:50] wei_pop_en             ) else `sauria_sva_error("Weights Feeder Doesn't Feed Data After Core Started");        
    assert property (@ (posedge i_clk) $rose(wei_pop_en)  |-> s_eventually mc_wei_done        ) else `sauria_sva_error("Weights Feeder Doesn't Finish Context After Feeding");          
    assert property (@ (posedge i_clk) $rose(mc_wei_done) |-> s_eventually mc_wei_til_done    ) else `sauria_sva_error("Weights Feeder Tile Doesn't Finish");          
    assert property (@ (posedge i_clk) $rose(wei_pop_en)  |-> ##[2:3] !mc_wei_stall           ) else `sauria_sva_error("Weights Feeder Stall And Feeding Indication Asserted Simultanously");
    assert property (@ (posedge i_clk) (wei_feeder_active && !wei_pop_en) |-> ##[1:3] mc_wei_stall) else `sauria_sva_error("Weights Feeder Doesn't Assert Stall When Not Feeding");

    assert property (@ (posedge i_clk) $rose(mc_start)    |=> $rose(ob_outbuf_start)                 ) else `sauria_sva_error("PSUMS Manager Doesn't Start After Core Started");        
    assert property (@ (posedge i_clk) $rose(ob_outbuf_start) |=> s_eventually $rose(mc_outbuf_done) ) else `sauria_sva_error("PSUMS Manager Doesn't Finish After Starting");        
    
    //Counts/Duration
    assert property (@ (posedge i_clk) $rose(sa_cscan_en)  |-> sa_cscan_en [*sauria_pkg::X]  ##1 $fell(sa_cscan_en) ) else `sauria_sva_error("Scan Chain Was Not Held For A Duration Equivalent to Width of Systolic Array");
    assert property (@ (posedge i_clk)  disable iff (!ob_preload_en) $rose(mc_start) |-> s_eventually $rose(cg_done)  ##0 (num_sramc_read  == ob_ncontexts) ) else `sauria_sva_error($sformatf("PSUMS Manager Did Not Start %0d SRAMC Read Bursts During A Computation", ob_ncontexts));        
    assert property (@ (posedge i_clk) $rose(mc_start) |-> s_eventually $rose(cg_done)  ##0 (num_sramc_write == ob_ncontexts) ) else `sauria_sva_error($sformatf("PSUMS Manager Did Not Start %0d SRAMC Write Bursts During A Computation", ob_ncontexts));        
    assert property (@ (posedge i_clk) $rose(ob_outbuf_start) |-> ##[1:$] $rose(ob_outbuf_start)  ##0 ((ctx_idx == (mc_incntlim - 1)) || (ctx_idx == '0)) ) else `sauria_sva_error($sformatf("Feeders Feeding Length Did Not Match INCNTLIM Exp: %0d Act: %0d", ob_ncontexts, ctx_idx));        
   
endmodule