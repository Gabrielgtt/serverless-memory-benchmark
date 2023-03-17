#!/bin/bash/

source ./vars.env

HEAP_CPUS=()

for heap_index in ${!HEAP_SIZES[@]}; do
    HEAP=${HEAP_SIZES[$heap_index]}  
    CPU=${CPUS[$heap_index]} 

    HEAP_CPU=${HEAP}${CPU::1}c
    HEAP_CPUS+=("$HEAP_CPU")
done

Rscript ../experiment-analysis/paper-plots.R "${GCS[*]}" "${HEAP_CPUS[*]}" "${BENCHMARKS[*]}" ${EXP_DATE} ${N}

