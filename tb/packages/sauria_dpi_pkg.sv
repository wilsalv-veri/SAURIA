`ifndef SAURIA_DPI_PKG
`define SAURIA_DPI_PKG
    
package sauria_dpi_pkg;

    import "DPI-C" function shortint unsigned fp16_mac(
        shortint unsigned a,
        shortint unsigned b,
        shortint unsigned acc
    );

endpackage

`endif //SAURIA_DPI_PKG
