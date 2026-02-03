import sauria_common_pkg::*;

interface sauria_axi4_lite_ifc;

    sauria_axi4_lite_rd_addr_ch_t axi4_lite_rd_addr_ch;
    sauria_axi4_lite_rd_data_ch_t axi4_lite_rd_data_ch;

    sauria_axi4_lite_wr_addr_ch_t axi4_lite_wr_addr_ch;
    sauria_axi4_lite_wr_data_ch_t axi4_lite_wr_data_ch;
    sauria_axi4_lite_wr_rsp_ch_t  axi4_lite_wr_rsp_ch;

endinterface

interface sauria_axi4_ifc;

    sauria_axi4_rd_addr_ch_t axi4_rd_addr_ch;
    sauria_axi4_rd_data_ch_t axi4_rd_data_ch;

    sauria_axi4_wr_addr_ch_t axi4_wr_addr_ch;
    sauria_axi4_wr_data_ch_t axi4_wr_data_ch;
    sauria_axi4_wr_rsp_ch_t  axi4_wr_rsp_ch;

endinterface