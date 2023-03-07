#!/bin/bash/

source ./vars.env

for heap in ${HEAP_SIZES[@]}; do
    for gc_index in ${!GCS[@]}; do
        for benchmark in ${BENCHMARKS[@]}; do
            bash parse-data.sh -r $N -g ${PARSERS[$gc_index]} -p ${INPUT_WD}exp-${GCS[$gc_index]}-$benchmark-$heap-
        done
    done
done

