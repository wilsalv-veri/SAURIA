class sauria_main_controller_scbd extends uvm_scoreboard;

    `uvm_component_utils(sauria_main_controller_scbd)

    string message_id = "SAURIA_MAIN_CONTROLLER_SCBD";

    sauria_main_controller_seq_item main_controller_item;

    `uvm_analysis_imp_decl (_main_controller_info)
    uvm_analysis_imp_main_controller_info #(sauria_main_controller_seq_item, sauria_main_controller_scbd) receive_main_controller_info;

    function new(string name="sauria_main_controller_scbd", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        receive_main_controller_info = new("SAURIA_MAIN_CONTROLLER_INFO_ANALYSIS_IMP", this);
    endfunction

    function write_main_controller_info(sauria_main_controller_seq_item main_controller_info);
        main_controller_item = main_controller_info;
    endfunction 
    
endclass