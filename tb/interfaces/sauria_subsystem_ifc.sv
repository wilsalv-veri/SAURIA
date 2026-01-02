interface sauria_subsystem_ifc;

    logic                               i_sauria_clk;
    logic                               i_system_clk;
    
    logic                               i_sauria_rstn;
    logic                               i_system_rstn;

    // Control FSM Interrupt
    logic                               o_intr;

    // DMA Interrupt
    logic                               o_reader_dmaintr;      // DMA reader completion interrupt
    logic                               o_writer_dmaintr;       // DMA writer completion interrupt
    
    // SAURIA Interrupt
    logic                               o_sauriaintr;           // SAURIA core completion interrupt


    //***************************************************** */
    modport master (
        input i_sauria_clk,
	    input i_sauria_rstn,

        input i_system_clk,
	    input i_system_rstn,

        output o_intr,

        output o_reader_dmaintr,       
        output o_writer_dmaintr,       
    
        output o_sauriaintr

    );

endinterface