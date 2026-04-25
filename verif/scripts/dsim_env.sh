
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

    rm -rf "$OUTPUT_DIR"

    # Ensure the output directory exists
    mkdir -p "$OUTPUT_DIR"

    # Run the dsim compilation command
    dsim -genimage sauria_subsystem -sv \
         -f "$SAURIA/verif/filelists/top_filelist.f" \
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

    # Check that $SAURIA is set before proceeding
    if [ -z "$SAURIA" ]; then
        echo "Error: SAURIA environment variable is not set."
        return 1
    fi
    
    #Ensure the test_runs directory exists
    mkdir -p $SAURIA/test_runs

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
            EXTRA_SIM_ARGS+=("$arg")
            REQUESTED_SV_SEED="${arg#-sv_seed=}"
        elif [[ "$arg" == sv_seed=* ]]; then
            EXTRA_SIM_ARGS+=("-${arg}")
            REQUESTED_SV_SEED="${arg#sv_seed=}"
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
    make_incremental_dir $SAURIA/test_runs/"$TEST_NAME"
    
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

    #Generate coverage report
    dcreport -out_dir $LAST_CREATED_DIR/cov_reports metrics.db
    mv metrics.db $LAST_CREATED_DIR/cov_reports

    #Move cov reports to their appropriate directory
    mv $LAST_CREATED_DIR/cov_reports/assert_*.html      $LAST_CREATED_DIR/cov_reports/assert_reports
    
    mv $LAST_CREATED_DIR/cov_reports/cg_detail_*.html   $LAST_CREATED_DIR/cov_reports/cg_reports
    mv $LAST_CREATED_DIR/cov_reports/functional_*.html  $LAST_CREATED_DIR/cov_reports/funct_reports

    #Move the waveform file to the test run directory
    mv SAURIA_waves.vcd $LAST_CREATED_DIR/"$DIR_NAME"_waves.vcd

    #Move the performance file to the test run directory and analyze it
    local PERF_CSV_PATH="$LAST_CREATED_DIR/SA_perf_data.csv"

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


