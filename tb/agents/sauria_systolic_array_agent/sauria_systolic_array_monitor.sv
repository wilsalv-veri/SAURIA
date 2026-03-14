class sauria_systolic_array_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_systolic_array_monitor)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_MONITOR";

    virtual sauria_systolic_array_ifc                   sauria_systolic_array_if;
    uvm_analysis_port #(sauria_systolic_array_seq_item) send_systolic_array_info;
    
    sauria_systolic_array_seq_item                      systolic_array_info;
    int                                                 cswitch_done_count = 0;

    arr_row_data_t      cswitch_arr_alternate, cswitch_arr_d, cswitch_arr_q; // Accumulator context switches
    arr_psum_reg_t      arr_psum_reserve_reg_d, arr_psum_reserve_reg_q;
    arr_psum_reg_t      arr_psum_accum_in_q; 
    arr_psum_reg_t      arr_psum_accum_out_q;

    bit                 cswitch_done_d, cswitch_done_q;
    bit                 pipeline_dis;
    bit                 pipeline_en_d, pipeline_en_q;

    bit normal_operation_pipeline_en;
    bit enabling_pipeline, disabling_pipeline; 
    bit sync_pipeline_after_dis; 

    function new(string name="sauria_systolic_array_monitor", uvm_component parent=null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        systolic_array_info          = sauria_systolic_array_seq_item::type_id::create("sauria_systolic_array_seq_item", this);
        send_systolic_array_info     = new("SAURIA_SYSTOLIC_ARRAY_ANALYSIS_PORT", this);
        
        if (!uvm_config_db #(virtual sauria_systolic_array_ifc)::get(this, "", "sauria_systolic_array_if", sauria_systolic_array_if))
            `sauria_error(message_id, "Failed to get access to sauria_systolic_array_if")

    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        fork 
            set_pipeline_en_info();
            get_systolic_array_info();
            wait_cswitch_done();
            get_cswitch_info();
            update_cswitch_done_count();
        join
    endtask

    virtual task get_systolic_array_info();
        forever @(posedge sauria_systolic_array_if.clk)begin
            if (normal_operation_pipeline_en || enabling_pipeline) begin
            
                systolic_array_info.a_arr       =  sauria_systolic_array_if.a_arr;    
                systolic_array_info.b_arr       =  sauria_systolic_array_if.b_arr;     
                systolic_array_info.i_c_arr     =  sauria_systolic_array_if.i_c_arr;   
                systolic_array_info.reg_clear   =  sauria_systolic_array_if.reg_clear;  
                systolic_array_info.pipeline_en =  sauria_systolic_array_if.pipeline_en;
                
                systolic_array_info.cswitch_arr =  cswitch_arr_q;
                systolic_array_info.cswitch_done_count = cswitch_done_count;
                
                systolic_array_info.cscan_en    =  sauria_systolic_array_if.cscan_en;   
                systolic_array_info.thres       =  sauria_systolic_array_if.thres;      
                systolic_array_info.o_c_arr     =  sauria_systolic_array_if.o_c_arr;  
                 
                systolic_array_info.arr_psum_reserve_reg = sauria_systolic_array_if.arr_psum_reserve_reg;
                systolic_array_info.pre_cswitch_arr_psum_reserve_reg = arr_psum_reserve_reg_q;

                systolic_array_info.arr_psum_accum_in  = arr_psum_accum_in_q; 
                systolic_array_info.arr_psum_accum_out = arr_psum_accum_out_q;
            
                send_systolic_array_info.write(systolic_array_info);
            end
        end
    endtask

    virtual task get_cswitch_info();

        forever @(posedge sauria_systolic_array_if.clk)begin
            
            if (normal_operation_pipeline_en || sync_pipeline_after_dis)  begin    
                cswitch_arr_d          <= sauria_systolic_array_if.cswitch_arr;
                arr_psum_reserve_reg_d <= sauria_systolic_array_if.arr_psum_reserve_reg;
                arr_psum_accum_in_q    <= sauria_systolic_array_if.arr_psum_accum_in;
                arr_psum_accum_out_q   <= sauria_systolic_array_if.arr_psum_accum_out;
            end
            
            if (disabling_pipeline || sync_pipeline_after_dis) 
                cswitch_arr_alternate <= (pipeline_dis == 1'b1) ? cswitch_arr_d : cswitch_arr_q; 
             
            cswitch_arr_q          <= (normal_operation_pipeline_en || !pipeline_dis) ? cswitch_arr_d:  cswitch_arr_alternate;
            arr_psum_reserve_reg_q <= arr_psum_reserve_reg_d;
            
            if (cswitch_done_d)begin
                cswitch_done_d <= 1'b0;
                cswitch_done_q <= 1'b1;      
            end
            else if (cswitch_done_q) cswitch_done_q <= 1'b0; //self-clearing            
        end
    endtask

    virtual task wait_cswitch_done();

        forever @ (sauria_systolic_array_if.cswitch_done_cb )begin
            if (pipeline_en_q)begin
                cswitch_done_d <= 1'b1;
            end  
        end
    endtask

    virtual task update_cswitch_done_count();

        forever @ (posedge sauria_systolic_array_if.clk)begin
            if (normal_operation_pipeline_en)begin
                if ((cswitch_done_q) || ((cswitch_done_count > 0) && 
                ((cswitch_done_count < sauria_pkg::X / 2))))
                    cswitch_done_count++; 
                else if (cswitch_done_count == (sauria_pkg::X / 2)) cswitch_done_count = 0;
            end
        end
                
    endtask

    virtual task set_pipeline_en_info();
        
        forever @ (posedge sauria_systolic_array_if.clk)begin
            pipeline_en_d <= sauria_systolic_array_if.pipeline_en;    
            pipeline_en_q <= pipeline_en_d; 

            if (disabling_pipeline || sync_pipeline_after_dis) 
                pipeline_dis          <= !normal_operation_pipeline_en; 
        
            normal_operation_pipeline_en = pipeline_en_q && pipeline_en_d;
            enabling_pipeline            = (pipeline_en_d && pipeline_dis);
            disabling_pipeline           = (pipeline_en_q && !pipeline_en_d);
            sync_pipeline_after_dis      = (sauria_systolic_array_if.pipeline_en && pipeline_dis);
        end

    endtask

endclass