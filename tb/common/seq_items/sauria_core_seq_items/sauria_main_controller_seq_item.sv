class sauria_main_controller_seq_item extends uvm_sequence_item;

    // Control Outputs (to Feeders)
    bit act_feeder_en;    // Enable for Row feeders
    bit act_feeder_clear; // Clear signal Row feeder buffers
    bit act_valid;        // Flag: valid inputs at feeder
    bit act_start;        // Flag: first inputs of current context
    bit act_finalpush;    // Flag: push of last buffer values
    bit act_cnt_en;       // Enable for counters
    bit act_cnt_clear;    // Clear signal for counters
    bit act_clearfifo;    // Clear signal for FIFO
    bit act_pop_en;       // FIFO pop enable
    bit act_finalctx;     // Final context flag for activation counters
    
    bit wei_feeder_en;    // Enable for Column feeders
    bit wei_feeder_clear; // Clear signal Column feeder buffers
    bit wei_valid;        // Flag: valid inputs at feeder
    bit wei_start;        // Flag: first inputs of current context
    bit wei_finalpush;    // Flag: push of last buffer values
    bit wei_cnt_en;       // Enable for counters
    bit wei_cnt_clear;    // Clear signal for counters
    bit wei_clearfifo;    // Clear signal for FIFO
    bit wei_pop_en;       // FIFO pop enable
    bit wei_cswitch;      // Context switch flag for weight counters

	// Control Outputs (Output Buffer)
    bit	outbuf_start;     // Start flag for output buffer
    bit outbuf_reset;     // Output buffer state Reset

    // Control Outputs (to Array)
    bit            sa_clear;     // Clear signal for SA internal registers
    bit            pipeline_en;  // Pipeline Enable signal for Array and Feeders
    arr_row_data_t cswitch_arr;  // Array Accumulator context switches

    // Control Outputs (to Interface)
    bit feed_deadlock; // Deadlock flag between feeders
    bit [4:0] ctx_status;
    bit [4:0] feed_status;
    bit done;          // Finish flag

    `uvm_object_utils_begin(sauria_main_controller_seq_item)
            
        `uvm_field_int(act_feeder_en    , UVM_ALL_ON) 
        `uvm_field_int(act_feeder_clear , UVM_ALL_ON) 
        `uvm_field_int(act_valid        , UVM_ALL_ON) 
        `uvm_field_int(act_start        , UVM_ALL_ON) 
        `uvm_field_int(act_finalpush    , UVM_ALL_ON) 
        `uvm_field_int(act_cnt_en       , UVM_ALL_ON) 
        `uvm_field_int(act_cnt_clear    , UVM_ALL_ON) 
        `uvm_field_int(act_clearfifo    , UVM_ALL_ON) 
        `uvm_field_int(act_pop_en       , UVM_ALL_ON) 
        `uvm_field_int(act_finalctx     , UVM_ALL_ON) 
    
        `uvm_field_int(wei_feeder_en    , UVM_ALL_ON)      
        `uvm_field_int(wei_feeder_clear , UVM_ALL_ON)         
        `uvm_field_int(wei_valid        , UVM_ALL_ON)      
        `uvm_field_int(wei_start        , UVM_ALL_ON)       
        `uvm_field_int(wei_finalpush    , UVM_ALL_ON)     
        `uvm_field_int(wei_cnt_en       , UVM_ALL_ON)    
        `uvm_field_int(wei_cnt_clear    , UVM_ALL_ON)  
        `uvm_field_int(wei_clearfifo    , UVM_ALL_ON) 
        `uvm_field_int(wei_pop_en       , UVM_ALL_ON)   
        `uvm_field_int(wei_cswitch      , UVM_ALL_ON)

        `uvm_field_int(outbuf_start     , UVM_ALL_ON)    
        `uvm_field_int(outbuf_reset     , UVM_ALL_ON)     

        `uvm_field_int(sa_clear         , UVM_ALL_ON)  
        `uvm_field_int(pipeline_en      , UVM_ALL_ON)    
        `uvm_field_int(cswitch_arr      , UVM_ALL_ON)  

        `uvm_field_int(feed_deadlock    , UVM_ALL_ON) 
        `uvm_field_int(ctx_status       , UVM_ALL_ON)
        `uvm_field_int(feed_status      , UVM_ALL_ON)
        `uvm_field_int(done             , UVM_ALL_ON) 

    `uvm_object_utils_end

    function new(string name="suaira_main_controller_seq_item");
        super.new(name);
    endfunction

endclass