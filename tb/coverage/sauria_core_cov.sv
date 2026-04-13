import sauria_pkg::*;
import sauria_common_pkg::*;

module sauria_core_cov (
                                                        input logic i_clk,

                                                        //Main Controller
                                                        input logic mc_start,
                                                        input logic sa_pipeline_en,
                                                        input logic mc_finalwrite,
                                                        input logic [sauria_pkg::ACT_IDX_W-1:0] mc_incntlim,
                                                        input logic [0:sauria_pkg::X-1] sa_cswitch_arr,
                                                        input logic sa_reg_clear,

                                                        input logic cg_done,

                                                        //IFMAPS Feeder
                                                        input logic af_act_clearfifo,
                                                        input logic af_act_cnt_clear,
                                                        input logic af_act_feeder_en,
                                                        input logic af_act_valid,
                                                        input logic af_act_start,
                                                        input logic [0:sauria_pkg::Y-1] af_rows_active,

                                                        input logic af_act_cnt_en,
                                                        input logic mc_act_stall,
                                                        input logic af_act_pop_en,
                                                        input logic mc_act_done,
                                                        input logic mc_act_til_done,
                                                        input logic mc_act_fifo_empty,
                                                        input logic mc_act_fifo_full,
                                                        input logic [sauria_pkg::OUT_IDX_W-1:0] mc_act_reps,
                                                        input logic o_srama_rden,

                                                        //Weight Feeder
                                                        input logic wf_wei_clearfifo,
                                                        input logic wf_wei_cnt_clear,
                                                        input logic wf_wei_feeder_en,
                                                        input logic wf_wei_valid,
                                                        input logic wf_wei_start,
                                                        input logic [0:sauria_pkg::X-1] wf_cols_active,
                                                        input logic wf_wei_cswitch,
                                                        input logic wf_waligned,

                                                        input logic wf_wei_cnt_en,
                                                        input logic mc_wei_stall,
                                                        input logic wf_wei_pop_en,
                                                        input logic mc_wei_done,
                                                        input logic mc_wei_til_done,
                                                        input logic mc_wei_fifo_empty,
                                                        input logic mc_wei_fifo_full,
                                                        input logic [sauria_pkg::OUT_IDX_W-1:0] mc_wei_reps,
                                                        input logic o_sramb_rden,

                                                        //PSUMS Manager
                                                        input logic ob_outbuf_start,
                                                        input logic [sauria_pkg::PARAMS_W-1:0] ob_inactive_cols,
                                                        input logic [sauria_pkg::OUT_IDX_W-1:0] ob_ncontexts,
                                                        input logic ob_preload_en,
                                                        input logic sa_cscan_en,
                                                        input logic mc_shift_done,
                                                        input logic o_sramc_rden,
                                                        input logic o_sramc_wren,
                                                        input logic mc_outbuf_done

                                                );

        covergroup sauria_core_cg @(posedge i_clk);
                option.per_instance = 1;

                //Main Controller cov
                coverpoint mc_start {
                        bins mc_start_cov                 = {1};
                }

                coverpoint sa_pipeline_en {
                        bins sa_pipeline_en_cov           = {1};
                }

                coverpoint mc_finalwrite {
                        bins mc_finalwrite_cov            = {1};
                }

                coverpoint sa_reg_clear {
                        bins sa_reg_clear_cov             = {1};
                }

                coverpoint cg_done {
                        bins cg_done_cov                  = {1};
                }

                coverpoint mc_incntlim {
                        bins mc_incntlim_zero             = {0};
                        bins mc_incntlim_non_zero         = {[1:$]};
                }

                SA_CSWITCH_ARR_ONEHOT_CP : coverpoint sa_cswitch_arr {
                        wildcard bins sa_cswitch_arr_onehot[] = {[0:(2**sauria_pkg::X)-1]} with ($onehot(item));
                }

                //IFMAPS Feeder cov
                coverpoint af_act_clearfifo {
                        bins af_act_clearfifo_cov         = {1};
                }

                coverpoint af_act_cnt_clear {
                        bins af_act_cnt_clear_cov         = {1};
                }

                coverpoint af_act_feeder_en {
                        bins af_act_feeder_en_cov         = {1};
                }

                coverpoint af_act_valid {
                        bins af_act_valid_cov             = {1};
                }

                coverpoint af_act_start {
                        bins af_act_start_cov             = {1};
                }

                AF_ROWS_ACTIVE_CP : coverpoint (af_rows_active == '0 ? 0 : (&af_rows_active ? 2 : 1)) {
                        bins af_rows_active_none          = {0};
                        bins af_rows_active_partial       = {1};
                        bins af_rows_active_all           = {2};
                }

                coverpoint af_act_cnt_en {
                        bins af_act_cnt_en_cov            = {1};
                }

                coverpoint mc_act_stall {
                        bins mc_act_stall_cov             = {1};
                }

                coverpoint af_act_pop_en {
                        bins af_act_pop_en_cov            = {1};
                }

                coverpoint mc_act_done {
                        bins mc_act_done_cov              = {1};
                }

                coverpoint mc_act_til_done {
                        bins mc_act_til_done_cov          = {1};
                }

                coverpoint mc_act_fifo_empty {
                        bins mc_act_fifo_empty_cov        = {1};
                }

                coverpoint mc_act_fifo_full {
                        bins mc_act_fifo_full_cov         = {1};
                }

                MC_ACT_REPS_GT_ZERO_CP : coverpoint (mc_act_reps > 0 ? 1 : 0) {
                        bins mc_act_reps_gt_zero          = {1};
                }

                coverpoint o_srama_rden {
                        bins o_srama_rden_cov             = {1};
                }

                //Weight Feeder cov
                coverpoint wf_wei_clearfifo {
                        bins wf_wei_clearfifo_cov         = {1};
                }

                coverpoint wf_wei_cnt_clear {
                        bins wf_wei_cnt_clear_cov         = {1};
                }

                coverpoint wf_wei_feeder_en {
                        bins wf_wei_feeder_en_cov         = {1};
                }

                coverpoint wf_wei_valid {
                        bins wf_wei_valid_cov             = {1};
                }

                coverpoint wf_wei_start {
                        bins wf_wei_start_cov             = {1};
                }

                WF_COLS_ACTIVE_CP : coverpoint (wf_cols_active == '0 ? 0 : (&wf_cols_active ? 2 : 1)) {
                        bins wf_cols_active_none          = {0};
                        bins wf_cols_active_partial       = {1};
                        bins wf_cols_active_all           = {2};
                }

                coverpoint wf_wei_cswitch {
                        bins wf_wei_cswitch_cov           = {1};
                }

                coverpoint wf_waligned {
                        bins wf_waligned_cov              = {1};
                }

                coverpoint wf_wei_cnt_en {
                        bins wf_wei_cnt_en_cov            = {1};
                }

                coverpoint mc_wei_stall {
                        bins mc_wei_stall_cov             = {1};
                }

                coverpoint wf_wei_pop_en {
                        bins wf_wei_pop_en_cov            = {1};
                }

                coverpoint mc_wei_done {
                        bins mc_wei_done_cov              = {1};
                }

                coverpoint mc_wei_til_done {
                        bins mc_wei_til_done_cov          = {1};
                }

                coverpoint mc_wei_fifo_empty {
                        bins mc_wei_fifo_empty_cov        = {1};
                }

                coverpoint mc_wei_fifo_full {
                        bins mc_wei_fifo_full_cov         = {1};
                }

                MC_WEI_REPS_GT_ZERO_CP : coverpoint (mc_wei_reps > 0 ? 1 : 0) {
                        bins mc_wei_reps_gt_zero          = {1};
                }

                coverpoint o_sramb_rden {
                        bins o_sramb_rden_cov             = {1};
                }

                //PSUMS Manager cov
                coverpoint ob_outbuf_start {
                        bins ob_outbuf_start_cov          = {1};
                }

                coverpoint ob_inactive_cols {
                        bins ob_inactive_cols_none        = {0};
                        bins ob_inactive_cols_some        = {[1:$]};
                }

                coverpoint ob_ncontexts {
                        bins ob_ncontexts_zero            = {0};
                        bins ob_ncontexts_non_zero        = {[1:$]};
                }

                coverpoint ob_preload_en {
                        bins ob_preload_en_cov            = {1};
                }

                coverpoint sa_cscan_en {
                        bins sa_cscan_en_cov              = {1};
                }

                coverpoint mc_shift_done {
                        bins mc_shift_done_cov            = {1};
                }

                coverpoint o_sramc_rden {
                        bins o_sramc_rden_cov             = {1};
                }

                coverpoint o_sramc_wren {
                        bins o_sramc_wren_cov             = {1};
                }

                coverpoint mc_outbuf_done {
                        bins mc_outbuf_done_cov           = {1};
                }

                //Core Crosses
                CORE_CTRL_FLOW                : cross mc_start, sa_pipeline_en, cg_done;
                CORE_FINALWRITE               : cross mc_finalwrite, sa_reg_clear;
                CORE_CSWITCH_PIPELINE         : cross SA_CSWITCH_ARR_ONEHOT_CP, sa_pipeline_en;

                //IFMAPS Crosses
                ACT_FEEDER_START              : cross af_act_start, af_act_feeder_en, af_act_valid;
                ACT_FEEDER_PROGRESS           : cross af_act_pop_en, mc_act_done, mc_act_til_done;
                ACT_FIFO_STATUS               : cross mc_act_fifo_empty, mc_act_fifo_full;

                //WEIGHTS Crosses
                WEI_FEEDER_START              : cross wf_wei_start, wf_wei_feeder_en, wf_wei_valid;
                WEI_FEEDER_PROGRESS           : cross wf_wei_pop_en, mc_wei_done, mc_wei_til_done;
                WEI_FIFO_STATUS               : cross mc_wei_fifo_empty, mc_wei_fifo_full;

                //Shape/Reps Crosses
                ACTIVE_ROWS_COLS              : cross AF_ROWS_ACTIVE_CP, WF_COLS_ACTIVE_CP;
                REPS_WITH_ACTIVE_SHAPE        : cross MC_ACT_REPS_GT_ZERO_CP, MC_WEI_REPS_GT_ZERO_CP, AF_ROWS_ACTIVE_CP, WF_COLS_ACTIVE_CP;

                //PSUMS Crosses
                OUTBUF_CTRL_FLOW              : cross ob_outbuf_start, ob_preload_en, sa_cscan_en, mc_outbuf_done;
                SRAMC_RW_ACTIVITY             : cross o_sramc_rden, o_sramc_wren;

        endgroup

        sauria_core_cg core_cg = new();

endmodule
                        