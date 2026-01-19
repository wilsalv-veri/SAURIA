class sauria_stand_alone_OFF_df_controller_cfg_seq extends sauria_axi4_lite_df_controller_cfg_base_seq;

    `uvm_object_utils(sauria_stand_alone_OFF_df_controller_cfg_seq)

    constraint stand_alone_cfg_c {
        stand_alone        == 1'b0;
        stand_alone_keep_A == 1'b0;
        stand_alone_keep_B == 1'b0;
        stand_alone_keep_C == 1'b0;  
    }

    function new(string name="sauria_stand_alone_OFF_df_controller_cfg_seq");
        super.new(name);
    endfunction

endclass