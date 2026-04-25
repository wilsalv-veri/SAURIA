class sauria_rand_core_weights_cfg_seq extends sauria_axi4_lite_core_weights_cfg_base_seq;

    `uvm_object_utils(sauria_rand_core_weights_cfg_seq)

    function new(string name="sauria_rand_core_weights_cfg_seq");
        super.new(name);
    endfunction

    constraint weights_aligned_flag_c {
        weights_aligned_flag dist {0 := 20, 1 := 80};
    }

    constraint weights_active_cols_c {
        weights_cols_active inside {
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'((1 << COLS_ACTIVE_SIZE) - 1)]
        };
        weights_cols_active dist {
            sauria_axi4_lite_data_t'((1 << COLS_ACTIVE_SIZE) - 1) := 70,
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'((1 << COLS_ACTIVE_SIZE) - 2)] :/ 30
        };
    }

endclass