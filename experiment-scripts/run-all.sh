#!/bin/bash/

# set -x

INPUT_WD="/home/gabriel.tavares/serverless-memory-benchmark/inputs/"

REPOSITORY=gc
TAG=latest
HEAP_SIZES=("256m" "512m" "1g" "2g" "4g")
WARMUP=3
N=20
GCS=("G1" "Serial" "Shenandoah")
BENCHMARKS=("dynamic-html")
INPUT_FILES=("input-dynamic-html-100000.json")
BATCH_SIZE=100
CPUS=("1.0" "1.0" "1.0" "2.0" "2.0")
FLAGS=""

for heap_index in ${!HEAP_SIZES[@]}; do
    for gc in ${GCS[@]}; do
        for benchmark_index in ${!BENCHMARKS[@]}; do
            sudo bash run.sh -r $REPOSITORY -t $TAG -h ${HEAP_SIZES[$heap_index]} -w $WARMUP -n $N -g $gc -b ${BENCHMARKS[$benchmark_index]} -i ${INPUT_WD}${INPUT_FILES[$benchmark_index]} -s $BATCH_SIZE -c ${CPUS[$heap_index]} > experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.out 2> experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.err
        done
    done
done

