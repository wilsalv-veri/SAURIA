class sauria_axi4_mem_base_seq extends uvm_sequence #(sauria_tensor_mem_seq_item);

    `uvm_object_utils(sauria_axi4_mem_base_seq)


    //Have CFG sequence generate cfg CRs
    //In parallel, send MEM sequence which will respond
    //to DMA read requests
    // Have AXI4 driver respond to read requests from DMA. 
    //Create monitor to record DMA writes. 
    //This eliminates need for large queues storing tensors

    string message_id           = "SAURIA_AXI4_MEM_BASE_SEQ";

    parameter MEM_BASE_OFFSET   = sauria_addr_pkg::DMA_OFFSET;

    sauria_axi_vseqr                vseqr;

    sauria_tensor_mem_seq_item      tensor_mem_seq_item;
    sauria_computation_params       computation_params;


    sauria_axi4_addr_t              awaddr; 
    rand sauria_ifmaps_elem_data_t  ifmaps_elem_data;
    rand sauria_weights_elem_data_t weights_elem_data;
    
    int                             weights_base_addr_offset;
    int                             weights_addr_offset;
    int                             ifmap_addr_offset;
    
    int                             ifmap_X;
    int                             ifmap_Y;
    int                             ifmap_C;
                                
    int                             weights_W;
    int                             weights_K;

    function new(string name="sauria_axi4_mem_base_seq");
        super.new(name);
    endfunction

    task body();
        get_computation_params();
        send_ifmap();
        send_weights();
    endtask

    virtual task get_computation_params();
        if (!uvm_config_db #(sauria_computation_params)::get(m_sequencer, "","computation_params", computation_params))
            `sauria_error(message_id, "Failed to get access to computation params")
  
        `sauria_info(message_id, "Getting Computation Params")
        wait(computation_params.shared);
        ifmap_X = computation_params.ifmap_X;
        ifmap_Y = computation_params.ifmap_Y;
        ifmap_C = computation_params.ifmap_C;
    endtask

    virtual task send_ifmap();

        `sauria_info(message_id, $sformatf("Sending IFMAPS C: %0d Y: %0d X: %0d", ifmap_C, ifmap_Y, ifmap_X))

        for(int c=0; c < ifmap_C; c++)begin
            for(int y=0; y < ifmap_Y; y++)begin
                
                create_tensor_seq_item_with_name($sformatf("IFMAP_C%0d_Y%0d", c, y));
                start_item(tensor_mem_seq_item); 
                `sauria_info(message_id, $sformatf("Grant for IFMAP_C%0d_Y%0d", c, y))
                ifmap_addr_offset = (c*ifmap_Y) + (y*ifmap_X);
                
                tensor_mem_seq_item.tensor_type = IFMAPS;
                set_tensor_row_addr(get_ifmaps_elem_aligned_address(ifmap_addr_offset));
                
                for(int x=0; x < ifmap_X; x++)begin
                    if (!this.randomize()) begin
                        `sauria_error(message_id, "Failed to randomize sauria_axi4_mem_base_seq")
                    end
                    add_ifmaps_elem(ifmaps_elem_data);
                    `sauria_info(message_id, $sformatf("Added X:%0d of %0d", x, ifmap_X))
                end
                finish_item(tensor_mem_seq_item);
                `sauria_info(message_id, $sformatf("Sent IFMAP_C%0d_Y%0d", c, y))
                
            end
        end
        weights_base_addr_offset = ifmap_addr_offset + ifmap_X;
    endtask

    virtual task send_weights();

        `sauria_info(message_id, "Sending WEIGHTS")
        
        for(int w=0; w < weights_W; w++)begin
           
            create_tensor_seq_item_with_name($sformatf("WEIGHTS_W%0d", w));
            start_item(tensor_mem_seq_item); 
            weights_addr_offset = (w*weights_K) + weights_base_addr_offset;
            tensor_mem_seq_item.tensor_type = WEIGHTS;
            
            for(int k=0; k < weights_K; k++)begin
                
                if (!this.randomize())
                    `sauria_error(message_id, "Failed to randomize sauria_axi4_mem_base_seq")
                
                add_weights_elem(weights_elem_data);
               
                finish_item(tensor_mem_seq_item);
            end
        end
    endtask

    virtual function void create_tensor_seq_item_with_name(string name);
        tensor_mem_seq_item = sauria_tensor_mem_seq_item::type_id::create(name);
    endfunction

    virtual function void set_tensor_row_addr(sauria_axi4_addr_t awaddr);
        tensor_mem_seq_item.row_addr = sauria_axi4_addr_t'(MEM_BASE_OFFSET + awaddr); 
    endfunction

    virtual function void add_ifmaps_elem(sauria_ifmaps_elem_data_t ifmaps_elem_data);
        tensor_mem_seq_item.ifmaps_elems.push_back(ifmaps_elem_data);
    endfunction

    virtual function void add_weights_elem(sauria_ifmaps_elem_data_t ifmaps_elem_data);
        tensor_mem_seq_item.weights_elems.push_back(ifmaps_elem_data);
    endfunction

    virtual function sauria_axi4_addr_t get_ifmaps_elem_aligned_address(int offset);
        return sauria_axi4_addr_t'(offset * df_ctrl_pkg::A_BYTES);
    endfunction

    virtual function sauria_axi4_addr_t get_weigths_elem_aligned_address(int offset);
        return sauria_axi4_addr_t'(offset * df_ctrl_pkg::B_BYTES);
    endfunction

endclass