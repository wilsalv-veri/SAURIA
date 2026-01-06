class sauria_axi4_lite_base_seq extends uvm_sequence #(sauria_axi_txn_base_seq_item);
      
    `uvm_object_utils(sauria_axi4_lite_base_seq)

    string message_id = "SAURIA_AXI4_LITE_BASE_SEQ";

    parameter CFG_BASE_OFFSET = sauria_addr_pkg::CONTROLLER_OFFSET;

    sauria_axi4_lite_wr_txn_seq_item axi4_lite_wr_txn_item;
    //sauria_cfg_cr_queue              cfg_cr_queue;

    sauria_axi4_lite_wr_txn_seq_item   cfg_cr_queue[SEQ_CFG_WRITES];
    int                                queue_running_idx;

    /*CFG CR Values */
    rand sauria_axi4_lite_data_t tile_x_lim;
    rand sauria_axi4_lite_data_t tile_y_lim;

    rand sauria_axi4_lite_data_t tile_c_lim;
    rand sauria_axi4_lite_data_t tile_k_lim;

    rand sauria_axi4_lite_data_t tile_psums_x_step;
    rand sauria_axi4_lite_data_t tile_psums_y_step;
    rand sauria_axi4_lite_data_t tile_psums_k_step;
    rand sauria_axi4_lite_data_t tile_ifmaps_x_step;
    rand sauria_axi4_lite_data_t tile_ifmaps_y_step;
    rand sauria_axi4_lite_data_t tile_ifmaps_c_step;
    rand sauria_axi4_lite_data_t tile_weights_k_step;
    rand sauria_axi4_lite_data_t tile_weights_c_step;
    rand sauria_axi4_lite_data_t ifmaps_y_lim;
    rand sauria_axi4_lite_data_t ifmaps_c_lim;
    rand sauria_axi4_lite_data_t psums_y_step;
    rand sauria_axi4_lite_data_t psums_k_step;
    rand sauria_axi4_lite_data_t ifmaps_y_step;
    rand sauria_axi4_lite_data_t ifmaps_c_step;
    
    rand bit stand_alone;
    rand bit stand_alone_keep_A;
    rand bit stand_alone_keep_B;
    rand bit stand_alone_keep_C;  
      
    rand sauria_axi4_lite_data_t weights_w_step;
    rand sauria_axi4_lite_data_t ifmaps_ett;
            
    rand sauria_axi4_lite_data_t start_SRAMA_addr;
    rand sauria_axi4_lite_data_t start_SRAMB_addr;
    rand sauria_axi4_lite_data_t start_SRAMC_addr;

    rand sauria_axi4_lite_data_t loop_order;
    rand bit                     Cw_eq;
    rand bit                     Ch_eq;
    rand bit                     Ck_eq;
    rand bit                     WXfer_op;

    function new(string name="sauria_axi4_lite_base_seq");
        super.new(name);

        //cfg_cr_queue = sauria_cfg_cr_queue::type_id::create("CFG_CR_QUEUE");

        stand_alone        = 1'b1;
        stand_alone_keep_A = 1'b1;
        stand_alone_keep_B = 1'b1;
        stand_alone_keep_C = 1'b1;  
    endfunction
  
    virtual task body();
        `sauria_info(message_id, "Starting Sequence")
        add_cfg_CRs_to_queue();
        send_cfg_CRs();
    endtask

    virtual task add_cfg_CRs_to_queue();
        enable_done_interrupt();
        add_rest_of_cfg_CRs();
        start_controller_fsm();
    endtask

    virtual task send_cfg_CRs();
        for(int idx=0; idx < $size(cfg_cr_queue); idx++)begin
            axi4_lite_wr_txn_item = cfg_cr_queue[idx];

            start_item(axi4_lite_wr_txn_item);
            finish_item(axi4_lite_wr_txn_item);
        end
    endtask

    virtual task add_rest_of_cfg_CRs();
        for(int cfg_cr_idx=0; cfg_cr_idx < N_SAURIA_CFG_WRITES; cfg_cr_idx++)begin
            create_wr_txn_with_name($sformatf("CFG_CR_IDX_%0d_wr_txn_item", cfg_cr_idx));
            
            set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('hf));
            set_cfg_cr_addr(get_cfg_addr_from_idx(cfg_cr_idx));
            
            case(cfg_cr_idx)
                0: begin
                    set_dma_tile_x_lim();
                    set_dma_tile_y_lim();
                end
                1: begin
                    set_dma_tile_c_lim();
                    set_dma_tile_k_lim();
                end
                2:  set_dma_tile_psums_x_step();
                3:  set_dma_tile_psums_y_step();
                4:  set_dma_tile_psums_k_step();
                5:  set_dma_tile_ifmaps_x_step();
                6:  set_dma_tile_ifmaps_y_step();
                7:  set_dma_tile_ifmaps_c_step();
                8:  set_dma_tile_weights_k_step();
                9:  set_dma_tile_weights_c_step();
                10: set_dma_ifmaps_y_lim();
                11: set_dma_ifmaps_c_lim();
                12: set_dma_psums_y_step();
                13: set_dma_psums_k_step();
                14: set_dma_ifmaps_y_step();
                15: set_dma_ifmaps_c_step();
                16: set_dma_weights_w_step();
                17: set_dma_ifmaps_ett();
                18: set_start_SRAMA_addr();
                19: set_start_SRAMB_addr();
                20: set_start_SRAMC_addr();
                21: begin
                    clear_start();
                    set_loop_order();
                    set_stand_alone_mode();
                    set_Cw_eq();
                    set_Ch_eq();
                    set_Ck_eq();
                    set_WXfer_op();
                end
            endcase  
            cfg_cr_queue[queue_running_idx++] = axi4_lite_wr_txn_item;
        end
    endtask
    
    virtual task enable_done_interrupt();
        create_wr_txn_with_name("done_interrupt_en_wr_txn_item");
        set_cfg_cr_addr(sauria_axi4_lite_addr_t'('h8));
        set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('h1));
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h1));
        cfg_cr_queue[queue_running_idx++] = axi4_lite_wr_txn_item;   
    endtask

    virtual function void set_dma_tile_x_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = tile_x_lim;
        set_cfg_cr_data(wdata);
    endfunction 

    virtual function void set_dma_tile_y_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = tile_y_lim;
        set_cfg_cr_data(wdata);
    endfunction 
   
    virtual function void set_dma_tile_c_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[15:0] = tile_c_lim;
        set_cfg_cr_data(wdata);
    endfunction 

    virtual function void set_dma_tile_k_lim();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31:16] = tile_k_lim;
        set_cfg_cr_data(wdata);
    endfunction 
    
    virtual function void set_dma_tile_psums_x_step();
        set_cfg_cr_data(tile_psums_x_step);
    endfunction
    
    virtual function void set_dma_tile_psums_y_step();
        set_cfg_cr_data(tile_psums_y_step);
    endfunction
    
    virtual function void set_dma_tile_psums_k_step();
        set_cfg_cr_data(tile_psums_k_step);
    endfunction

    virtual function void set_dma_tile_ifmaps_x_step();
        set_cfg_cr_data(tile_ifmaps_x_step);
    endfunction
    
    virtual function void set_dma_tile_ifmaps_y_step();
        set_cfg_cr_data(tile_ifmaps_y_step);
    endfunction
    
    virtual function void set_dma_tile_ifmaps_c_step();
        set_cfg_cr_data(tile_ifmaps_c_step);
    endfunction

    virtual function void set_dma_tile_weights_k_step();
        set_cfg_cr_data(tile_weights_k_step);
    endfunction
    
    virtual function void set_dma_tile_weights_c_step();
        set_cfg_cr_data(tile_weights_c_step);
    endfunction

    virtual function void set_dma_ifmaps_y_lim();
        set_cfg_cr_data(ifmaps_y_lim);
    endfunction

    virtual function void set_dma_ifmaps_c_lim();
        set_cfg_cr_data(ifmaps_c_lim);
    endfunction

    virtual function void set_dma_psums_y_step();
        set_cfg_cr_data(psums_y_step);
    endfunction
    
    virtual function void set_dma_psums_k_step();
        set_cfg_cr_data(psums_k_step);
    endfunction

    virtual function void set_dma_ifmaps_y_step();
        set_cfg_cr_data(ifmaps_y_step);
    endfunction

    virtual function void set_dma_ifmaps_c_step();
        set_cfg_cr_data(ifmaps_c_step);
    endfunction

    virtual function void set_dma_weights_w_step();
        set_cfg_cr_data(weights_w_step);
    endfunction
    
    virtual function void set_dma_ifmaps_ett();
        set_cfg_cr_data(ifmaps_ett);
    endfunction

    virtual function void set_start_SRAMA_addr();
        set_cfg_cr_data(start_SRAMA_addr);
    endfunction

    virtual function void set_start_SRAMB_addr();
        set_cfg_cr_data(start_SRAMB_addr);
    endfunction

    virtual function void set_start_SRAMC_addr();
        set_cfg_cr_data(start_SRAMC_addr);
    endfunction

    virtual function void set_loop_order();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[17:16] = loop_order;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void clear_start();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[22] = 1'b1; //!start
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_stand_alone_mode();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[18] = stand_alone;
        wdata[19] = stand_alone_keep_A;
        wdata[20] = stand_alone_keep_B;
        wdata[21] = stand_alone_keep_C;   
        
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_Cw_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[23] = Cw_eq;
        set_cfg_cr_data(wdata);
    endfunction
   
    virtual function void set_Ch_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[24] = Ch_eq;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_Ck_eq();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[25] = Ck_eq;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function void set_WXfer_op();
        sauria_axi4_lite_data_t wdata = get_cfg_cr_data();
        wdata[31] = WXfer_op;
        set_cfg_cr_data(wdata);
    endfunction

    virtual function start_controller_fsm();
        create_wr_txn_with_name("start_fsm_wr_txn_item");
        set_cfg_cr_addr(sauria_axi4_lite_addr_t'('h0));
        set_cfg_cr_strobe(sauria_axi4_lite_strobe_t'('h1));
        set_cfg_cr_data(sauria_axi4_lite_data_t'('h1));
        cfg_cr_queue[queue_running_idx++] = axi4_lite_wr_txn_item;   
    endfunction

    virtual function void create_wr_txn_with_name(string name);
        axi4_lite_wr_txn_item = sauria_axi4_lite_wr_txn_seq_item::type_id::create(name);
    endfunction

    virtual function void set_cfg_cr_strobe(sauria_axi4_lite_strobe_t wstrb);
        axi4_lite_wr_txn_item.wr_data_item.wstrb = wstrb; 
    endfunction

    virtual function void set_cfg_cr_addr(sauria_axi4_lite_addr_t awaddr);
        axi4_lite_wr_txn_item.wr_addr_item.awaddr = sauria_axi4_lite_addr_t'(CFG_BASE_OFFSET + awaddr); 
    endfunction

    virtual function void set_cfg_cr_data( sauria_axi4_lite_data_t wdata);
        axi4_lite_wr_txn_item.wr_data_item.wdata = wdata;
    endfunction

    virtual function  sauria_axi4_lite_data_t get_cfg_cr_data();
        return axi4_lite_wr_txn_item.wr_data_item.wdata;
    endfunction

    virtual function sauria_axi4_lite_addr_t get_cfg_addr_from_idx(int cfg_cr_idx);
        return sauria_axi4_lite_addr_t'('h10 + cfg_cr_idx*4);
    endfunction

endclass
