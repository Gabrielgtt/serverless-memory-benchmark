#!/bin/bash/

# set -x

# bash parse-data.sh -r 10 -g Shenandoah -p /home/moranguinho/mestrado/serverless-memory-benchmark/experiment-analysis/results/exp-17-10/exp-Shenandoah-dynamic-html-4g-

INPUT_WD="/home/moranguinho/mestrado/serverless-memory-benchmark/experiment-analysis/results/exp-14-12/"

HEAP_SIZES=("256m" "512m" "1g" "2g" "4g")
# HEAP_SIZES=("20g2c" "20g1c")
N=20
GCS=("G1" "Serial" "Shenandoah")
PARSERS=("G1" "G1" "Shenandoah")
# GCS=("Epsilon")
# PARSERS=("Epsilon")
BENCHMARKS=("graph-bfs")

for heap in ${HEAP_SIZES[@]}; do
    for gc_index in ${!GCS[@]}; do
        for benchmark in ${BENCHMARKS[@]}; do
            bash parse-data.sh -r $N -g ${PARSERS[$gc_index]} -p ${INPUT_WD}exp-${GCS[$gc_index]}-$benchmark-$heap-
        done
    done
done

