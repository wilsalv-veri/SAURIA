class sauria_axi4_lite_core_main_controller_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_main_controller_cfg_base_seq)

    rand sauria_axi4_lite_data_t total_macs;
    rand sauria_axi4_lite_data_t act_reps;
                        
    rand sauria_axi4_lite_data_t weight_reps;
    rand sauria_axi4_lite_data_t psums_reps;
    
    rand sauria_axi4_lite_data_t zero_negligence_threshold;                
   
    
    constraint total_macs_c {
        total_macs == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint array_reps_c {
        act_reps    == sauria_axi4_lite_data_t'('h1);                    
        weight_reps == sauria_axi4_lite_data_t'('h1);
        psums_reps  == sauria_axi4_lite_data_t'('h5);
    }
   
    constraint zero_neg_c{
        zero_negligence_threshold == sauria_axi4_lite_data_t'('h0);                
    }

    
    function new(string name="sauria_axi4_lite_core_main_controller_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_MAIN_CONTROLLER_CFG_BASE_SEQ";
        
        queue_start_idx = CORE_MAIN_CONTROLLER_CFG_CRs_START_IDX;
        queue_end_idx   = CORE_MAIN_CONTROLLER_CFG_CRs_END_IDX;

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_core_main_controller_cfg_base_seq")
    endfunction

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_core_main_controller_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_core_main_controller_cfg_CRs(int cfg_cr_idx);
            
        case(cfg_cr_idx)
            22: begin
                set_total_macs();
                set_act_reps();
                set_weight_reps_lower();
            end
            23:begin
                set_weight_reps_upper();
                set_zero_negligence_threshold();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;
      
    endfunction
   
    virtual function void set_total_macs();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[14:0] = total_macs;
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_act_reps();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:15] = act_reps;
        set_cfg_cr_data(wdata);
    endfunction
        
    virtual function void set_weight_reps_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = weight_reps[1:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_weight_reps_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:0] = weight_reps[14:2];
        set_cfg_cr_data(wdata);
    endfunction

    //Finish Later
    virtual function void set_zero_negligence_threshold();
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h0));
    endfunction
    
endclass