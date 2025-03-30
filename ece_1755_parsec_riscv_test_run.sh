#!/usr/bin/bash
set -e # Exit immediately if a command exits with a non-zero status.

# Check if parallel is installed
if ! command -v parallel &> /dev/null; then
    echo "Error: GNU parallel is not installed. Please install it (e.g., 'sudo apt install parallel' or 'brew install parallel') and try again."
    exit 1
fi

# List of available PARSEC benchmarks
benchmarks=(
    blackscholes
    # bodytrack
    canneal
    dedup
    # facesim
    # ferret
    fluidanimate
    freqmine
    # raytrace
    streamcluster
    # swaptions
    # vips
    # x264
)

# Simulation sizes
sizes=(simsmall
#  simmedium
#  simlarge
)

# Number of cores for simulation configuration (passed as argument to gem5)
# This is different from the number of parallel HOST jobs
num_cores_sim=(
    1
    4
    8
    16
    32
)

# Maximum number of parallel jobs to run ON THE HOST SYSTEM
MAX_JOBS=10

# Base output directory
BASE_OUTDIR="riscv_results"
LOG_DIR="$BASE_OUTDIR/logs"

# Create necessary directories
mkdir -p "$LOG_DIR"

echo "Starting simulations using GNU parallel with up to $MAX_JOBS concurrent host jobs..."

# Use ::: to provide input lists to parallel
# {1} will be the benchmark (bm)
# {2} will be the size (sz)
# {3} will be the number of simulation cores (nc)
parallel \
    --jobs "$MAX_JOBS" \
    --eta \
    --joblog "$LOG_DIR/parallel_joblog.txt" \
    --tagstring "{1}_{2}_{3}" \
    '
    # Assign placeholders to variables for clarity inside the command block
    bm="{1}"
    sz="{2}"
    nc="{3}"

    # Construct the specific output directory for this job
    outdir="'"$BASE_OUTDIR"'/${bm}_${sz}_${nc}" # Note quoting to handle BASE_OUTDIR from outer script

    # Print status message (will be interleaved by parallel)
    echo "Starting: Benchmark=$bm, Size=$sz, Cores=$nc -> Output=$outdir"

    # Create the specific output directory
    mkdir -p "$outdir"

    # Execute the gem5 command, redirecting output to its log file
    ./build/RISCV/gem5.opt --outdir="$outdir" configs/ece1755/riscv-fs.py \
        --benchmark "$bm" \
        --size "$sz" \
        --num-cores "$nc" > "$outdir/sim.log" 2>&1

    # Check exit status (optional but good practice, parallel also logs it)
    if [[ $? -eq 0 ]]; then
        echo "SUCCESS: $bm $sz $nc finished."
    else
        echo "FAILURE: $bm $sz $nc failed. Check $outdir/sim.log"
        # parallel automatically records the non-zero exit code in the joblog
    fi
    ' ::: "${benchmarks[@]}" ::: "${sizes[@]}" ::: "${num_cores_sim[@]}"
    # ^^^ Input lists for parallel processing ^^^

echo "All simulations managed by GNU parallel have finished or failed."
echo "Check job status details in $LOG_DIR/parallel_joblog.txt"