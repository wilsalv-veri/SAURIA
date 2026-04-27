
#DSIM_LICENSE VAR : Uncomment Below
#export DSIM_LICENSE=path/to/license/here

#DSIM VAR : Uncomment Below
#export DSIM=path/to/Altair_DSIM/here

#SAURIA VAR : Uncomment Below
#export SAURIA=path/to/SAURIA/here

export UVM_HOME=$DSIM/2025.1/uvm/2020.3.1

source $DSIM/2025.1/shell_activate.bash

export RTL_DIR=$(pwd)/RTL
export PULP_DIR=$(pwd)/pulp_platform

export TEST_DIR=$(pwd)/test

function compile_sauria(){
    # Check that $SAURIA is set before proceeding
    if [ -z "$SAURIA" ]; then
        echo "Error: SAURIA environment variable is not set."
        return 1
    fi
    
    local OUTPUT_DIR="$SAURIA/output"
    local DPI_LIB="$SAURIA/verif/dpi/sauria_dpi.so"

    rm -rf "$OUTPUT_DIR"

    # Ensure the output directory exists
    mkdir -p "$OUTPUT_DIR"

    if [ ! -f "$DPI_LIB" ]; then
        echo "DPI shared library not found at $DPI_LIB. Building it now..."
        if ! make -C "$SAURIA/verif/dpi"; then
            echo "Error: failed to build DPI shared library."
            return 1
        fi
    fi

    # Run the dsim compilation command
    dsim -genimage sauria_subsystem -sv \
         -f "$SAURIA/verif/filelists/top_filelist.f" \
            -sv_lib "$DPI_LIB" \
         -timescale 1ns/1ps \
         -top SAURIA_tb_top +acc+b -uvm 2020.3.1 

    # Move the dsim output files to the designated output directory
    mv dsim* "$OUTPUT_DIR/"
}

#Run Function
function run_sauria(){

    local TEST_NAME="$1"
    shift
    local EXTRA_SIM_ARGS=()
    local EXPECT_SV_SEED_VALUE=0
    local REQUESTED_SV_SEED=""
    local RESOLVED_SV_SEED=""
    local RUN_RESULT=1

    # Check that $SAURIA is set before proceeding
    if [ -z "$SAURIA" ]; then
        echo "Error: SAURIA environment variable is not set."
        return 1
    fi
    
    local RUNS_ROOT="${SAURIA_RUNS_ROOT:-$SAURIA/test_runs}"

    #Ensure the target runs directory exists
    mkdir -p "$RUNS_ROOT"

    if [ -z "$TEST_NAME" ]; then
        echo "Error: Please provide a test name."
        return 1
    fi

    for arg in "$@"; do
        if [ "$EXPECT_SV_SEED_VALUE" -eq 1 ]; then
            EXTRA_SIM_ARGS+=("$arg")
            REQUESTED_SV_SEED="$arg"
            EXPECT_SV_SEED_VALUE=0
        elif [[ "$arg" == "-sv_seed" ]]; then
            EXTRA_SIM_ARGS+=("$arg")
            EXPECT_SV_SEED_VALUE=1
        elif [[ "$arg" == -sv_seed=* ]]; then
            REQUESTED_SV_SEED="${arg#-sv_seed=}"
            EXTRA_SIM_ARGS+=("-sv_seed" "$REQUESTED_SV_SEED")
        elif [[ "$arg" == sv_seed=* ]]; then
            REQUESTED_SV_SEED="${arg#sv_seed=}"
            EXTRA_SIM_ARGS+=("-sv_seed" "$REQUESTED_SV_SEED")
        elif [[ "$arg" == *=* && "$arg" != +* && "$arg" != -* ]]; then
            EXTRA_SIM_ARGS+=("+$arg")
        else
            EXTRA_SIM_ARGS+=("$arg")
        fi
    done

    if [ "$EXPECT_SV_SEED_VALUE" -eq 1 ]; then
        echo "Error: -sv_seed requires a value. Use -sv_seed <seed> or -sv_seed=<seed>."
        return 1
    fi

    #Create directory for current test run
    make_incremental_dir "$RUNS_ROOT/$TEST_NAME"
    
    local DIR_NAME=$(basename "$LAST_CREATED_DIR")
    mkdir $LAST_CREATED_DIR/cov_reports

    mkdir $LAST_CREATED_DIR/cov_reports/assert_reports
    mkdir $LAST_CREATED_DIR/cov_reports/cg_reports
    mkdir $LAST_CREATED_DIR/cov_reports/funct_reports
    
    echo "Starting $DIR_NAME"

    if [ ${#EXTRA_SIM_ARGS[@]} -gt 0 ]; then
        echo "Extra simulator args: ${EXTRA_SIM_ARGS[*]}"
    fi

    if [ -n "$REQUESTED_SV_SEED" ]; then
        echo "Requested simulator seed: $REQUESTED_SV_SEED"
    else
        echo "Requested simulator seed: auto"
    fi
    
    #Run the dsim test run command on compiled image
    dsim -image sauria_subsystem -work $SAURIA/output/dsim_work \
        -uvm 2020.3.1      \
        -sv_lib "$SAURIA/verif/dpi/sauria_dpi.so" \
        -dump-agg -waves SAURIA_waves.vcd +UVM_TESTNAME="$TEST_NAME" \
        "${EXTRA_SIM_ARGS[@]}" \
        &> "SAURIA_run.log" \
    
    echo "Finished $DIR_NAME"
    
    # Move the dsim output files to the designated output directory
    mv dsim* $SAURIA/output/

    if [ -f "$SAURIA/output/dsim.log" ]; then
        local SEED_LINE
        SEED_LINE=$(grep -m1 "Random seed:" "$SAURIA/output/dsim.log" 2>/dev/null)
        if [[ "$SEED_LINE" =~ ([0-9]+) ]]; then
            RESOLVED_SV_SEED="${BASH_REMATCH[1]}"
            echo "Resolved simulator seed: $RESOLVED_SV_SEED"
        else
            echo "Warning: unable to parse resolved simulator seed from $SAURIA/output/dsim.log"
        fi
    fi

    mv "SAURIA_run.log" "$LAST_CREATED_DIR/SAURIA_run.log"

    {
        echo "test_name=$TEST_NAME"
        echo "run_dir=$DIR_NAME"
        echo "requested_sv_seed=${REQUESTED_SV_SEED:-auto}"
        echo "resolved_sv_seed=${RESOLVED_SV_SEED:-unknown}"
        echo "extra_sim_args=${EXTRA_SIM_ARGS[*]}"
    } > "$LAST_CREATED_DIR/run_metadata.txt"

    #Generate individual logs
    python3 $SAURIA/verif/scripts/generate_logs.py $LAST_CREATED_DIR 

    local SA_PASS_LOG="$LAST_CREATED_DIR/SA_pass.log"
    local SA_FAIL_LOG="$LAST_CREATED_DIR/SA_fail.log"

    if [ -s "$SA_FAIL_LOG" ]; then
        RUN_RESULT=1
        echo "Test verdict: FAIL (non-empty SA_fail.log)"
    elif [ -s "$SA_PASS_LOG" ]; then
        RUN_RESULT=0
        echo "Test verdict: PASS (SA_pass.log present and SA_fail.log absent)"
    else
        RUN_RESULT=1
        echo "Warning: neither SA_pass.log nor SA_fail.log contained data; marking test as FAIL"
    fi

    #Generate coverage report
    if [ -f "metrics.db" ]; then
        dcreport -out_dir $LAST_CREATED_DIR/cov_reports metrics.db
        mv metrics.db $LAST_CREATED_DIR/cov_reports
    else
        echo "Warning: metrics.db not found, skipping coverage report generation"
    fi

    #Move cov reports to their appropriate directory
    for f in "$LAST_CREATED_DIR"/cov_reports/assert_*.html; do
        [ -f "$f" ] && mv "$f" "$LAST_CREATED_DIR/cov_reports/assert_reports/"
    done
    for f in "$LAST_CREATED_DIR"/cov_reports/cg_detail_*.html; do
        [ -f "$f" ] && mv "$f" "$LAST_CREATED_DIR/cov_reports/cg_reports/"
    done
    for f in "$LAST_CREATED_DIR"/cov_reports/functional_*.html; do
        [ -f "$f" ] && mv "$f" "$LAST_CREATED_DIR/cov_reports/funct_reports/"
    done

    #Move the waveform file to the test run directory
    if [ -f "SAURIA_waves.vcd" ]; then
        mv SAURIA_waves.vcd "$LAST_CREATED_DIR/${DIR_NAME}_waves.vcd"
    else
        echo "Warning: SAURIA_waves.vcd not found, skipping waveform move"
    fi

    #Move the performance file to the test run directory and analyze it
    local PERF_CSV_PATH="$LAST_CREATED_DIR/SA_perf_data.csv"

    if [ -f "SA_perf_log.csv" ]; then
        mv SA_perf_log.csv "$PERF_CSV_PATH"
        if [ -d "$SAURIA/verif/scripts/perf_analyzer" ]; then
            echo "Analyzing performance CSV: $PERF_CSV_PATH"
            if PYTHONPATH="$SAURIA/verif/scripts${PYTHONPATH:+:$PYTHONPATH}" python3 -m perf_analyzer "$PERF_CSV_PATH"; then
                echo "Performance report generated at ${PERF_CSV_PATH%.csv}_perf_analysis/perf_report.html"
            else
                echo "Warning: performance analysis failed for $PERF_CSV_PATH"
            fi
        else
            echo "Warning: performance analyzer package not found at $SAURIA/verif/scripts/perf_analyzer"
        fi
    else
        echo "Warning: SA_perf_log.csv not found, skipping performance analysis"
    fi

    return "$RUN_RESULT"

}

function trim_whitespace() {
    local VALUE="$1"
    VALUE="${VALUE#"${VALUE%%[![:space:]]*}"}"
    VALUE="${VALUE%"${VALUE##*[![:space:]]}"}"
    echo "$VALUE"
}

function run_sauria_regression(){
    local TEST_LIST_FILE="$1"
    local REGRESSION_NAME=""

    # Check that $SAURIA is set before proceeding
    if [ -z "$SAURIA" ]; then
        echo "Error: SAURIA environment variable is not set."
        return 1
    fi

    if [ -z "$TEST_LIST_FILE" ]; then
        echo "Error: Please provide a regression test list file."
        return 1
    fi

    if [ ! -f "$TEST_LIST_FILE" ]; then
        echo "Error: Regression test list file not found: $TEST_LIST_FILE"
        return 1
    fi

    REGRESSION_NAME="$(basename "$TEST_LIST_FILE")"

    local REGRESSION_ROOT="$SAURIA/test_runs/$REGRESSION_NAME"
    mkdir -p "$SAURIA/test_runs"
    make_incremental_dir "$REGRESSION_ROOT"

    local REGRESSION_RUN_DIR="$LAST_CREATED_DIR"
    local SUMMARY_FILE="$REGRESSION_RUN_DIR/regression_summary.txt"
    local RUN_LOG_FILE="$REGRESSION_RUN_DIR/regression_run.log"
    local RESULTS_LOG_FILE="$REGRESSION_RUN_DIR/regression_results.log"
    local PREVIOUS_RUNS_ROOT="${SAURIA_RUNS_ROOT:-}"
    local TEST_INDEX=0
    local TOTAL_TESTS=0
    local PASS_COUNT=0
    local FAIL_COUNT=0
    local REGRESSION_ANALYSIS_RC=0

    TOTAL_TESTS=$(awk '
        {
            line=$0
            sub(/^[ \t]+/, "", line)
            if (line == "" || line ~ /^#/) {
                next
            }
            count++
        }
        END { print count + 0 }
    ' "$TEST_LIST_FILE")

    # Keep detailed run output only in the run log; use fd 3 for live progress messages.
    exec 3>&1 4>&2
    exec >> "$RUN_LOG_FILE" 2>&1

    : > "$SUMMARY_FILE"
    : > "$RESULTS_LOG_FILE"

    {
        echo "regression_name=$REGRESSION_NAME"
        echo "regression_dir=$REGRESSION_RUN_DIR"
        echo "test_list_file=$TEST_LIST_FILE"
        echo "schema=test_name | optional simulator args"
        echo "notes=lines beginning with # are ignored"
        echo "--------------------------------------------------"
    } > "$SUMMARY_FILE"

    {
        echo "regression_name=$REGRESSION_NAME"
        echo "regression_dir=$REGRESSION_RUN_DIR"
        echo "test_list_file=$TEST_LIST_FILE"
        echo "started_at=$(date '+%Y-%m-%d %H:%M:%S %Z')"
        echo "--------------------------------------------------"
    } > "$RESULTS_LOG_FILE"

    echo "Starting regression: $REGRESSION_RUN_DIR"
    echo "Regression run log: $RUN_LOG_FILE"
    echo "Regression results log: $RESULTS_LOG_FILE"

    echo "Starting regression: $REGRESSION_RUN_DIR" >&3
    echo "Detailed log: $RUN_LOG_FILE" >&3
    echo "Results log: $RESULTS_LOG_FILE" >&3
    echo "Total tests: $TOTAL_TESTS" >&3

    while IFS= read -r RAW_LINE || [ -n "$RAW_LINE" ]; do
        local LINE
        LINE=$(trim_whitespace "$RAW_LINE")

        if [ -z "$LINE" ] || [[ "$LINE" == \#* ]]; then
            continue
        fi

        local TEST_NAME_PART
        local SIM_ARGS_PART
        local TEST_NAME
        local TEST_RC
        local TEST_STATUS
        local TEST_RUN_DIR="N/A"
        local TEST_ARGS=()

        if [[ "$LINE" == *"|"* ]]; then
            TEST_NAME_PART="${LINE%%|*}"
            SIM_ARGS_PART="${LINE#*|}"
        else
            TEST_NAME_PART="$LINE"
            SIM_ARGS_PART=""
        fi

        TEST_NAME=$(trim_whitespace "$TEST_NAME_PART")
        SIM_ARGS_PART=$(trim_whitespace "$SIM_ARGS_PART")

        if [ -z "$TEST_NAME" ]; then
            continue
        fi

        TEST_INDEX=$((TEST_INDEX + 1))

        if [ -n "$SIM_ARGS_PART" ]; then
            # Basic schema: args are whitespace-separated tokens.
            read -r -a TEST_ARGS <<< "$SIM_ARGS_PART"
        fi

        echo "[$TEST_INDEX/$TOTAL_TESTS] Running '$TEST_NAME'" >&3
        echo "[$TEST_INDEX/$TOTAL_TESTS] Running test '$TEST_NAME'"
        export SAURIA_RUNS_ROOT="$REGRESSION_RUN_DIR"
        run_sauria "$TEST_NAME" "${TEST_ARGS[@]}"
        TEST_RC=$?

        if [ -n "$LAST_CREATED_DIR" ]; then
            TEST_RUN_DIR="$LAST_CREATED_DIR"
        fi

        if [ "$TEST_RC" -eq 0 ]; then
            PASS_COUNT=$((PASS_COUNT + 1))
            TEST_STATUS="PASS"
            echo "[$TEST_INDEX/$TOTAL_TESTS] PASS: $TEST_NAME" >&3
            echo "[$TEST_INDEX/$TOTAL_TESTS] PASS: $TEST_NAME"
        else
            FAIL_COUNT=$((FAIL_COUNT + 1))
            TEST_STATUS="FAIL"
            echo "[$TEST_INDEX/$TOTAL_TESTS] FAIL: $TEST_NAME (rc=$TEST_RC)" >&3
            echo "[$TEST_INDEX/$TOTAL_TESTS] FAIL: $TEST_NAME (rc=$TEST_RC)"
        fi

        {
            echo "index=$TEST_INDEX test_name=$TEST_NAME rc=$TEST_RC run_dir=$TEST_RUN_DIR args=${TEST_ARGS[*]}"
        } >> "$SUMMARY_FILE"

        {
            echo "index=$TEST_INDEX status=$TEST_STATUS test_name=$TEST_NAME rc=$TEST_RC run_dir=$TEST_RUN_DIR args=${TEST_ARGS[*]}"
        } >> "$RESULTS_LOG_FILE"
    done < "$TEST_LIST_FILE"

    if [ -n "$PREVIOUS_RUNS_ROOT" ]; then
        export SAURIA_RUNS_ROOT="$PREVIOUS_RUNS_ROOT"
    else
        unset SAURIA_RUNS_ROOT
    fi

    {
        echo "--------------------------------------------------"
        echo "total_tests=$TEST_INDEX"
        echo "passed=$PASS_COUNT"
        echo "failed=$FAIL_COUNT"
    } >> "$SUMMARY_FILE"

    if [ -d "$SAURIA/verif/scripts/perf_analyzer" ]; then
        echo "Running regression-wide perf analysis for: $REGRESSION_RUN_DIR"
        echo "Running regression-wide perf analysis..." >&3
        if PYTHONPATH="$SAURIA/verif/scripts${PYTHONPATH:+:$PYTHONPATH}" python3 -m perf_analyzer "$REGRESSION_RUN_DIR"; then
            REGRESSION_ANALYSIS_RC=0
            echo "Regression-wide perf analysis: PASS"
            echo "Regression-wide perf analysis: PASS" >&3
        else
            REGRESSION_ANALYSIS_RC=1
            echo "Warning: regression-wide perf analysis failed for $REGRESSION_RUN_DIR"
            echo "Regression-wide perf analysis: FAIL" >&3
        fi
    else
        echo "Warning: perf analyzer package not found at $SAURIA/verif/scripts/perf_analyzer"
        echo "Regression-wide perf analysis: SKIPPED (package missing)" >&3
    fi

    {
        echo "--------------------------------------------------"
        echo "total_tests=$TEST_INDEX"
        echo "passed=$PASS_COUNT"
        echo "failed=$FAIL_COUNT"
        echo "regression_perf_analysis_rc=$REGRESSION_ANALYSIS_RC"
        echo "ended_at=$(date '+%Y-%m-%d %H:%M:%S %Z')"
    } >> "$RESULTS_LOG_FILE"

    echo "Regression finished: total=$TEST_INDEX pass=$PASS_COUNT fail=$FAIL_COUNT"
    echo "Summary: $SUMMARY_FILE"
    echo "Results: $RESULTS_LOG_FILE"

    echo "Regression finished: total=$TEST_INDEX pass=$PASS_COUNT fail=$FAIL_COUNT" >&3
    echo "Summary: $SUMMARY_FILE" >&3
    echo "Results: $RESULTS_LOG_FILE" >&3

    exec 1>&3 2>&4
    exec 3>&- 4>&-

    if [ "$FAIL_COUNT" -gt 0 ] || [ "$REGRESSION_ANALYSIS_RC" -ne 0 ]; then
        return 1
    fi

    return 0
}

function make_incremental_dir() {
    # 1. Check if the user provided a directory name
    if [ -z "$1" ]; then
        echo "Error: Please provide a base directory name."
        return 1
    fi

    # 2. Define the base path and counter
    local BASE_NAME="$1"
    local INCREMENT=0
    local TARGET_DIR="$BASE_NAME"

    # 3. Loop until a unique directory name is found
    while [ -d "$TARGET_DIR" ]; do
        # If the directory exists, increment the counter
        INCREMENT=$((INCREMENT + 1))
        
        # Build the new directory name with the appended number
        TARGET_DIR="${BASE_NAME}.${INCREMENT}"
        
        # Safety break: Prevent infinite loops after a large number of tries
        if [ "$INCREMENT" -ge 1000 ]; then
            echo "Error: Exceeded 1000 attempts to find a unique directory name."
            return 1
        fi
    done

    # 4. Create the unique directory
    mkdir "$TARGET_DIR"

    # 5. Report and return the created directory name
    echo "Created directory: $TARGET_DIR"
    
    # Export the final directory name so the calling script/shell can use it
    export LAST_CREATED_DIR="$TARGET_DIR"
}


