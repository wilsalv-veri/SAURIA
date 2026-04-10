class sauria_plusarg_utils;

    typedef struct {
        bit is_registered;
        string valid_values[$];
        int min_numeric_value;
        int max_numeric_value;
    } plusarg_spec_t;

    typedef enum int {
        PLUSARG_NOT_FOUND,
        PLUSARG_APPLIED,
        PLUSARG_INVALID
    } plusarg_override_status_t;

    static plusarg_spec_t plusarg_registry[string];

    static function automatic void register_plusarg(string plusarg_name);
        plusarg_spec_t plusarg_spec;

        if (!plusarg_registry.exists(plusarg_name)) begin
            plusarg_spec.is_registered = 1;
            plusarg_spec.min_numeric_value = 0;
            plusarg_spec.max_numeric_value = -1;
            plusarg_registry[plusarg_name] = plusarg_spec;
        end else begin
            plusarg_registry[plusarg_name].is_registered = 1;
        end
    endfunction

    static function automatic void register_plusarg_values(
        string plusarg_name,
        string valid_values[$],
        int min_numeric_value,
        int max_numeric_value
    );
        register_plusarg(plusarg_name);
        plusarg_registry[plusarg_name].valid_values = valid_values;
        plusarg_registry[plusarg_name].min_numeric_value = min_numeric_value;
        plusarg_registry[plusarg_name].max_numeric_value = max_numeric_value;
    endfunction

    static function automatic bit has_registered_plusarg(string plusarg_name);
        return plusarg_registry.exists(plusarg_name) && plusarg_registry[plusarg_name].is_registered;
    endfunction

    static function automatic bit has_plusarg(string plusarg_name);
        return $test$plusargs(plusarg_name);
    endfunction

    static function automatic bit get_plusarg_string(string plusarg_name, output string value);
        return $value$plusargs({plusarg_name, "=%s"}, value);
    endfunction

    static function automatic bit get_plusarg_value_if_exists(string plusarg_name, output string value);
        if (!has_plusarg(plusarg_name))
            return 0;

        return get_plusarg_string(plusarg_name, value);
    endfunction

    static function automatic bit is_decimal_string(string str);
        if (str.len() == 0) return 0;

        for (int idx = 0; idx < str.len(); idx++) begin
            byte curr_char = str.getc(idx);
            if ((curr_char < "0") || (curr_char > "9"))
                return 0;
        end

        return 1;
    endfunction

    static function automatic bit parse_enum_by_name_or_int(
        string raw_value,
        string enum_name_lut[$],
        int enum_min,
        int enum_max,
        output int enum_value
    );
        string value_upper;
        int parsed_value;

        value_upper = raw_value.toupper();

        foreach (enum_name_lut[idx]) begin
            if (value_upper == enum_name_lut[idx].toupper()) begin
                enum_value = enum_min + idx;
                return 1;
            end
        end

        if (is_decimal_string(raw_value)) begin
            parsed_value = raw_value.atoi();
            if ((parsed_value >= enum_min) && (parsed_value <= enum_max)) begin
                enum_value = parsed_value;
                return 1;
            end
        end

        return 0;
    endfunction

    static function automatic plusarg_override_status_t apply_registered_plusarg_override(
        string plusarg_name,
        ref int value,
        output string raw_value
    );
        int parsed_value;
        plusarg_spec_t plusarg_spec;

        raw_value = "";

        if (!has_registered_plusarg(plusarg_name))
            return PLUSARG_NOT_FOUND;

        if (!get_plusarg_value_if_exists(plusarg_name, raw_value))
            return PLUSARG_NOT_FOUND;

        plusarg_spec = plusarg_registry[plusarg_name];

        if (parse_enum_by_name_or_int(raw_value, plusarg_spec.valid_values, plusarg_spec.min_numeric_value, plusarg_spec.max_numeric_value, parsed_value)) begin
            value = parsed_value;
            return PLUSARG_APPLIED;
        end

        return PLUSARG_INVALID;
    endfunction

    static function automatic void get_int_data_mode_values(
        output string values[$],
        output int min_numeric_value,
        output int max_numeric_value
    );
        int_data_gen_mode_t mode;

        values.delete();
        mode = mode.first();

        min_numeric_value = int'(mode.first());
        max_numeric_value = int'(mode.last());

        while (1) begin
            values.push_back(mode.name());
            if (mode == mode.last())
                break;
            mode = mode.next();
        end
    endfunction

    static function automatic void get_fp_data_mode_values(
        output string values[$],
        output int min_numeric_value,
        output int max_numeric_value
    );
        fp_data_gen_mode_t mode;

        values.delete();
        mode = mode.first();

        min_numeric_value = int'(mode.first());
        max_numeric_value = int'(mode.last());

        while (1) begin
            values.push_back(mode.name());
            if (mode == mode.last())
                break;
            mode = mode.next();
        end
    endfunction

endclass
