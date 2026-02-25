class sauria_axi4_lite_core_ifmaps_cfg_base_seq extends sauria_axi4_lite_cfg_base_seq;

    `uvm_object_utils(sauria_axi4_lite_core_ifmaps_cfg_base_seq)

    sauria_computation_params    computation_params;

    rand sauria_axi4_lite_data_t ifmaps_x_lim;
    rand sauria_axi4_lite_data_t ifmaps_x_step;
    rand sauria_axi4_lite_data_t ifmaps_y_lim;
                            
    rand sauria_axi4_lite_data_t ifmaps_y_step;
    rand sauria_axi4_lite_data_t ifmaps_ch_lim;
                          
    rand sauria_axi4_lite_data_t ifmaps_ch_step;
    rand sauria_axi4_lite_data_t ifmaps_tile_x_lim;
                           
    rand sauria_axi4_lite_data_t ifmaps_tile_x_step;
    rand sauria_axi4_lite_data_t ifmaps_tile_y_lim;
                         
    rand sauria_axi4_lite_data_t ifmaps_tile_y_step;
    rand logic[63:0]             dilation_pattern;
                              
    rand sauria_axi4_lite_data_t ifmaps_rows_active;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_0;
                             
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_1;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_2;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_3;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_4;
                            
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_5;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_6;
    rand sauria_axi4_lite_data_t ifmaps_loc_woffs_7;
   
    constraint ifmaps_dimensions_c{
        ifmaps_x_lim   == sauria_axi4_lite_data_t'('h0);
        ifmaps_y_lim   == sauria_axi4_lite_data_t'('h0);
        ifmaps_ch_lim  == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint ifmaps_dimension_steps_c{
        ifmaps_x_step  == sauria_axi4_lite_data_t'('h0);
        ifmaps_y_step  == sauria_axi4_lite_data_t'('h0);
        ifmaps_ch_step == sauria_axi4_lite_data_t'('h0);
    }
                         
    constraint ifmaps_tile_dimensions_c{
        ifmaps_tile_x_lim == sauria_axi4_lite_data_t'('h0);                       
        ifmaps_tile_y_lim == sauria_axi4_lite_data_t'('h0);
    }
    
    constraint ifmaps_tile_dimension_steps_c{
        ifmaps_tile_x_step == sauria_axi4_lite_data_t'('h0);
        ifmaps_tile_y_step == sauria_axi4_lite_data_t'('h0);
    }

    constraint dilation_pattern_c{
        dilation_pattern == 64'h0101010101010101;
    }
        
    constraint ifmaps_loc_woffs_c{
        ifmaps_loc_woffs_0 == sauria_axi4_lite_data_t'('h0);                         
        ifmaps_loc_woffs_1 == sauria_axi4_lite_data_t'('h0);
        ifmaps_loc_woffs_2 == sauria_axi4_lite_data_t'('h0);
        ifmaps_loc_woffs_3 == sauria_axi4_lite_data_t'('h0);
        ifmaps_loc_woffs_4 == sauria_axi4_lite_data_t'('h0);          
        ifmaps_loc_woffs_5 == sauria_axi4_lite_data_t'('h0);
        ifmaps_loc_woffs_6 == sauria_axi4_lite_data_t'('h0);
        ifmaps_loc_woffs_7 == sauria_axi4_lite_data_t'('h0);
    }

    constraint ifmpas_active_inactive_rows_c{
        ifmaps_rows_active == sauria_axi4_lite_data_t'('hff);
    }

    function new(string name="sauria_axi4_lite_core_ifmaps_cfg_base_seq");
        super.new(name);
        message_id = "SAURIA_AXI4_LITE_CORE_IFMAPS_CFG_BASE_SEQ";

        queue_start_idx = CORE_IFMAPS_CFG_CRs_START_IDX;
        queue_end_idx   = CORE_IFMAPS_CFG_CRs_END_IDX;

        if(!this.randomize())
            `sauria_error(message_id, "Failed to randomize sauria_axi4_lite_core_ifmaps_cfg_base_seq")
    endfunction

    virtual task body();
        get_ifmaps_params();
        super.body();
    endtask

    virtual function void add_unit_specific_cfg_CRs(int cfg_cr_idx);
        add_core_ifmaps_cfg_CRs(cfg_cr_idx);
    endfunction

    virtual function void add_core_ifmaps_cfg_CRs(int cfg_cr_idx);

        case(cfg_cr_idx)
            24:begin
                set_ifmaps_x_lim();
                set_ifmaps_x_step();
                set_ifmaps_y_lim_lower();
            end
            25:begin
                set_ifmaps_y_lim_upper();
                set_ifmaps_y_step();
                set_ifmaps_ch_lim_lower();
            end
            26:begin
                set_ifmaps_ch_lim_upper();
                set_ifmaps_ch_step();
                set_ifmaps_tile_x_lim_lower();
            end
            27:begin
                set_ifmaps_tile_x_lim_upper();
                set_ifmaps_tile_x_step();
                set_ifmaps_tile_y_lim_lower();
            end
            28: begin
                set_ifmaps_tile_y_lim_upper();
                set_ifmaps_tile_y_step();
                set_dilation_pattern_lower();
            end
            29: begin
                set_dilation_pattern_second_byte();
            end
            30: begin
                set_dilation_pattern_upper();
                set_ifmaps_rows_active();
                set_ifmaps_loc_woffs_0_lower();
            end
            31: begin
                set_ifmaps_loc_woffs_0_upper();
                set_ifmaps_loc_woffs_1();
                set_ifmaps_loc_woffs_2();
                set_ifmaps_loc_woffs_3();
                set_ifmaps_loc_woffs_4_lower();
            end
            32:begin
                set_ifmaps_loc_woffs_0_upper();
                set_ifmaps_loc_woffs_5();
                set_ifmaps_loc_woffs_6();
                set_ifmaps_loc_woffs_7();
            end
        endcase
        cfg_cr_queue[cfg_cr_idx] = axi4_lite_wr_txn_item;

    endfunction

    virtual task get_ifmaps_params();

        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
        
        wait(computation_params.shared);
       
        ifmaps_x_step = computation_params.ifmaps_x_step;
        ifmaps_y_step = computation_params.ifmaps_y_step;
        ifmaps_ch_step = computation_params.ifmaps_c_step;

        ifmaps_x_lim  = computation_params.ifmaps_X;       
        ifmaps_y_lim  = computation_params.ifmaps_Y * ifmaps_y_step;         
        ifmaps_ch_lim = computation_params.ifmaps_C * ifmaps_ch_step;         

        
        ifmaps_tile_x_lim = computation_params.tile_ifmaps_X;
        ifmaps_tile_y_lim = computation_params.tile_ifmaps_Y;
    
        ifmaps_tile_x_step = computation_params.tile_ifmaps_x_step;
        ifmaps_tile_y_step = computation_params.tile_ifmaps_y_step;
    endtask

    virtual function void set_ifmaps_x_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[14:0] = ifmaps_x_lim;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_x_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:15] = ifmaps_x_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_y_lim_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = ifmaps_y_lim[1:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_y_lim_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[12:0] = ifmaps_y_lim[14:2];
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_ifmaps_y_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[27:13] = ifmaps_y_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_ch_lim_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:28] = ifmaps_ch_lim[3:0];
        set_cfg_cr_data(wdata);
    endfunction
        
    virtual function void set_ifmaps_ch_lim_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[10:0] = ifmaps_ch_lim[14:4];
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_ifmaps_ch_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[25:11] = ifmaps_ch_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_tile_x_lim_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:26] = ifmaps_tile_x_lim[5:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_tile_x_lim_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[8:0] = ifmaps_tile_x_lim[14:6];
        set_cfg_cr_data(wdata);
    endfunction
            
    virtual function void set_ifmaps_tile_x_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[23:9] = ifmaps_tile_x_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_tile_y_lim_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:24] = ifmaps_tile_y_lim[7:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_tile_y_lim_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[6:0] = ifmaps_tile_y_lim[14:8];
        set_cfg_cr_data(wdata);
    endfunction
                
    virtual function void set_ifmaps_tile_y_step();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[21:7] = ifmaps_tile_y_step;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_dilation_pattern_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:22] = dilation_pattern[9:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_dilation_pattern_second_byte();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata = dilation_pattern[41:10];
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_dilation_pattern_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[21:0] = dilation_pattern[63:42];
        set_cfg_cr_data(wdata);
    endfunction
    
    virtual function void set_ifmaps_rows_active();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:22] = ifmaps_rows_active;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_0_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = ifmaps_loc_woffs_0[1:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_0_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[5:0] = ifmaps_loc_woffs_0[7:2];
        set_cfg_cr_data(wdata);
    endfunction
    
                
    virtual function void set_ifmaps_loc_woffs_1();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[13:6] = ifmaps_loc_woffs_1;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_2();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[21:14] = ifmaps_loc_woffs_2;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_3();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:22] = ifmaps_loc_woffs_3;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_4_lower();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:30] = ifmaps_loc_woffs_4[1:0];
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_4_upper();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[5:0] = ifmaps_loc_woffs_4[7:2];
        set_cfg_cr_data(wdata);
    endfunction
    
                
    virtual function void set_ifmaps_loc_woffs_5();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[13:6] = ifmaps_loc_woffs_5;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_6();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[21:14] = ifmaps_loc_woffs_6;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_ifmaps_loc_woffs_7();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[29:22] = ifmaps_loc_woffs_7;
        set_cfg_cr_data(wdata);
    endfunction
    
endclass