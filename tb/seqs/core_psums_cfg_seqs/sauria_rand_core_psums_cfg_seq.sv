class sauria_rand_core_psums_cfg_seq extends sauria_axi4_lite_core_psums_cfg_base_seq;

    `uvm_object_utils(sauria_rand_core_psums_cfg_seq)

    function new(string name="sauria_rand_core_psums_cfg_seq");
        super.new(name);
    endfunction

    constraint psums_preload_en_c {
        psums_preload_en dist {sauria_axi4_lite_data_t'('h0) := 70, sauria_axi4_lite_data_t'('h1) := 30};
    }

    constraint psums_inactive_cols_c {
        psums_inactive_cols inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'(COLS_ACTIVE_SIZE - 1)]};
        psums_inactive_cols dist {
            sauria_axi4_lite_data_t'('h0) := 70,
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'(COLS_ACTIVE_SIZE - 1)] :/ 30
        };
    }

endclass