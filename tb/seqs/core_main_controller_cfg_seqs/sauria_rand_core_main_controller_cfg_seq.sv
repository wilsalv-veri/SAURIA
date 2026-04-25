class sauria_rand_core_main_controller_cfg_seq extends sauria_axi4_lite_core_main_controller_cfg_base_seq;

    `uvm_object_utils(sauria_rand_core_main_controller_cfg_seq)

    function new(string name="sauria_rand_core_main_controller_cfg_seq");
        super.new(name);
    endfunction

    constraint zero_neg_c {
        zero_negligence_threshold dist {
            sauria_axi4_lite_data_t'('h0) := 80,
            [sauria_axi4_lite_data_t'('h1):sauria_axi4_lite_data_t'('hf)] :/ 20
        };
    }

endclass