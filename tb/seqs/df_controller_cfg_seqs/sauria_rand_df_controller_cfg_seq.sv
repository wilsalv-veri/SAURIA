class sauria_rand_df_controller_cfg_seq extends sauria_axi4_lite_df_controller_cfg_base_seq;

    `uvm_object_utils(sauria_rand_df_controller_cfg_seq)

    function new(string name="sauria_rand_df_controller_cfg_seq");
        super.new(name);
    endfunction

    constraint stand_alone_cfg_c {
        stand_alone        == 1'b0;
        stand_alone_keep_A == 1'b0;
        stand_alone_keep_B == 1'b0;
        stand_alone_keep_C == 1'b0;  
    }

    constraint eq_flags_c {
        Cw_eq dist {0:=70, 1:=30};
        Ch_eq dist {0:=70, 1:=30};
        Ck_eq dist {0:=70, 1:=30};

        Cw_eq == 1'b0;
        Ch_eq == 1'b0;
        Ck_eq == 1'b0;
    }

    constraint loop_order_c {
        loop_order dist {0:=50, [1:2]:/50};
        loop_order == 2'b0;
    }
    
    constraint wxfer_op_c {
        WXfer_op dist {0:=70, 1:=30};
    }

endclass