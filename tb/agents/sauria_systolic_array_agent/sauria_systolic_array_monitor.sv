class sauria_systolic_array_monitor extends uvm_monitor;

    `uvm_component_utils(sauria_systolic_array_monitor)

    string message_id = "SAURIA_SYSTOLIC_ARRAY_MONITOR";

    virtual sauria_systolic_array_ifc                   sauria_systolic_array_if;
    uvm_analysis_port #(sauria_systolic_array_seq_item) send_systolic_array_info;
    
    sauria_systolic_array_seq_item                      systolic_array_info;
    
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
            get_systolic_array_info();
        join
    endtask

    virtual task get_systolic_array_info();
        forever @(posedge sauria_systolic_array_if.clk)begin
            if (sauria_systolic_array_if.pipeline_en)begin
                systolic_array_info.a_arr       =  sauria_systolic_array_if.a_arr;    
                systolic_array_info.b_arr       =  sauria_systolic_array_if.b_arr;     
                systolic_array_info.i_c_arr     =  sauria_systolic_array_if.i_c_arr;   
                systolic_array_info.reg_clear   =  sauria_systolic_array_if.reg_clear;  
                systolic_array_info.pipeline_en =  sauria_systolic_array_if.pipeline_en;
                systolic_array_info.cswitch_arr =  sauria_systolic_array_if.cswitch_arr;
                systolic_array_info.cscan_en    =  sauria_systolic_array_if.cscan_en;   
                systolic_array_info.thres       =  sauria_systolic_array_if.thres;      
                systolic_array_info.o_c_arr     =  sauria_systolic_array_if.o_c_arr;  
                
                systolic_array_info.arr_psum_reserve_reg = sauria_systolic_array_if.arr_psum_reserve_reg;
                systolic_array_info.arr_psum_accum       = sauria_systolic_array_if.arr_psum_accum;
            
                send_systolic_array_info.write(systolic_array_info);
            end
        end
    endtask

endclass