class sauria_feeder_base_model extends uvm_object;

    `uvm_object_utils(sauria_feeder_base_model)

    protected string                    message_id;
    protected sauria_computation_params computation_params;
    protected bit                       is_configured;
    protected sauria_axi4_lite_data_t   incntlim;
    protected sauria_axi4_lite_data_t   comp_feeding_len;
    protected sauria_axi4_lite_data_t   idx_curr_comp;
    protected sauria_axi4_lite_data_t   idx_next_comp;
    protected bit                       overlapping_comps;

    function new(string name="sauria_feeder_base_model");
        super.new(name);
        message_id = "SAURIA_FEEDER_BASE_MODEL";
    endfunction

    protected function void set_message_id(string message_id);
        this.message_id = message_id;
    endfunction

    protected function void set_incntlim_and_comp_feeding_len(sauria_axi4_lite_data_t incntlim,
                                                              int unsigned            feeder_dim);
        this.incntlim        = incntlim;
        this.comp_feeding_len = incntlim + feeder_dim;
    endfunction

    protected function void reset_overlap_tracking();
        idx_curr_comp     = 0;
        idx_next_comp     = 0;
        overlapping_comps = 1'b0;
    endfunction

    virtual function void set_computation_params(sauria_computation_params computation_params);
        this.computation_params = computation_params;
        is_configured           = 1'b0;
    endfunction

    protected virtual function void ensure_configured();
        if (is_configured)
            return;

        if (computation_params == null)
            `sauria_fatal(message_id, "Computation params handle was not provided")

        validate_configuration_ready();
        configure_from_computation_params();
    endfunction

    protected virtual function void validate_configuration_ready();
        `sauria_fatal(message_id, "validate_configuration_ready must be overridden")
    endfunction

    protected virtual function void configure_from_computation_params();
        `sauria_fatal(message_id, "configure_from_computation_params must be overridden")
    endfunction

endclass