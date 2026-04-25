class sauria_rand_core_ifmaps_cfg_seq extends sauria_axi4_lite_core_ifmaps_cfg_base_seq;

    `uvm_object_utils(sauria_rand_core_ifmaps_cfg_seq)

    function new(string name="sauria_rand_core_ifmaps_cfg_seq");
        super.new(name);
    endfunction

    //FIXME: wilsalv
    //Need to add support in the ifmaps feeders model
    /*
    constraint ifmaps_loc_woffs_c {
        ifmaps_loc_woffs_0 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_1 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_2 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_3 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_4 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_5 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_6 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};
        ifmaps_loc_woffs_7 inside {[sauria_axi4_lite_data_t'('h0):sauria_axi4_lite_data_t'('h7)]};

        unique {
            ifmaps_loc_woffs_0,
            ifmaps_loc_woffs_1,
            ifmaps_loc_woffs_2,
            ifmaps_loc_woffs_3,
            ifmaps_loc_woffs_4,
            ifmaps_loc_woffs_5,
            ifmaps_loc_woffs_6,
            ifmaps_loc_woffs_7
        };
    }
    */

    constraint ifmpas_active_inactive_rows_c {
        ifmaps_rows_active inside {
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'((1 << ROWS_ACTIVE_SIZE) - 1)]
        };
        ifmaps_rows_active dist {
            sauria_axi4_lite_data_t'((1 << ROWS_ACTIVE_SIZE) - 1) := 70,
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'((1 << ROWS_ACTIVE_SIZE) - 2)] :/ 30
        };
    }

endclass