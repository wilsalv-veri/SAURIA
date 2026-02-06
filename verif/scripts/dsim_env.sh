
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

    # Check that $SAURIA is set before proceeding
    if [ -z "$SAURIA" ]; then
        echo "Error: SAURIA environment variable is not set."
        return 1
    fi
    
    #Ensure the test_runs directory exists
    mkdir -p $SAURIA/test_runs

    #Create directory for current test run
    make_incremental_dir $SAURIA/test_runs/"$1"
    
    local DIR_NAME=$(basename "$LAST_CREATED_DIR")
    mkdir $LAST_CREATED_DIR/cov_reports

    mkdir $LAST_CREATED_DIR/cov_reports/assert_reports
    mkdir $LAST_CREATED_DIR/cov_reports/cg_reports
    mkdir $LAST_CREATED_DIR/cov_reports/funct_reports
    
    echo "Starting $DIR_NAME"

    #Run the dsim test run command on compiled image
    dsim -image sauria_subsystem -work $SAURIA/output/dsim_work \
        -uvm 2020.3.1      \
        -dump-agg -waves SAURIA_waves.vcd +UVM_TESTNAME="$1" \
        &> "SAURIA_run.log" \
    
    echo "Finished $DIR_NAME"
    
    # Move the dsim output files to the designated output directory
    mv dsim* $SAURIA/output/

    #Generate individual logs
    python3 $SAURIA/verif/scripts/generate_logs.py $LAST_CREATED_DIR 

    #Generate coverage report
    dcreport -out_dir $LAST_CREATED_DIR/cov_reports metrics.db
    mv metrics.db $LAST_CREATED_DIR/cov_reports

    #Move cov reports to their appropriate directory
    mv $LAST_CREATED_DIR/cov_reports/assert_*.html      $LAST_CREATED_DIR/cov_reports/assert_reports
    
    #FIXME: wilsalv :Add back once UVM tests have been enabled
    mv $LAST_CREATED_DIR/cov_reports/cg_detail_*.html   $LAST_CREATED_DIR/cov_reports/cg_reports
    mv $LAST_CREATED_DIR/cov_reports/functional_*.html  $LAST_CREATED_DIR/cov_reports/funct_reports

    #Move the waveform file to the test run directory
    mv SAURIA_waves.vcd $LAST_CREATED_DIR/"$DIR_NAME"_waves.vcd

    rm "SAURIA_run.log"
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


