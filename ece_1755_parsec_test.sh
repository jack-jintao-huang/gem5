#!/usr/bin/env bash

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

# TODO NUM_CORES

for bm in "${benchmarks[@]}"; do
    for sz in "${sizes[@]}"; do
        outdir="results/${bm}_${sz}"
        mkdir -p "$outdir"
        ./build/X86/gem5.opt --outdir="$outdir" configs/ece1755/x86-parsec-benchmarks.py \
            --benchmark "$bm" \
            --size "$sz"
    done
done