
package sauria_cfg_pkg;

    //NOTE: wilsalv :
    //Verification added knob to bypass the im2col behavior of the data feeder
    //Behavior in the dataflow controller is to modify memory layout to look
    //GeMM native such that there is no overlop between tiles.

    `ifdef SAURIA_DV_GEMM_BYPASS
        localparam DV_GEMM_BYPASS = `SAURIA_DV_GEMM_BYPASS;
    `else
        localparam DV_GEMM_BYPASS = 1'b0;
    `endif
    
endpackage