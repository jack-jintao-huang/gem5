#!/usr/bin/bash

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

num_cores=(
    1
    4
    8
    16
    32
)

for bm in "${benchmarks[@]}"; do
    for sz in "${sizes[@]}"; do
        for nc in "${num_cores[@]}"; do
            outdir="results/${bm}_${sz}_${nc}"
            mkdir -p "$outdir"
            ./build/X86/gem5.opt --outdir="$outdir" configs/ece1755/x86-parsec-benchmarks.py \
                --benchmark "$bm" \
                --size "$sz" \
                --num-cores "$nc"
        done
    done
done