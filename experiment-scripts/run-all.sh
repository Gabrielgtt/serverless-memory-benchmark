#!/bin/bash/

# set -x

INPUT_WD="/home/moranguinho/mestrado/serverless-memory-benchmark/inputs/"

REPOSITORY=gc
TAG=latest
HEAP_SIZES=("512m")
WARMUP=1
N=1
GCS=("G1")
BENCHMARKS=("video-processing")
INPUT_FILES=("input-video-processing.json")
BATCH_SIZE=100
CPUS=("2.0")
FLAGS=""

for heap_index in ${!HEAP_SIZES[@]}; do
    for gc in ${GCS[@]}; do
        for benchmark_index in ${!BENCHMARKS[@]}; do
            sudo bash run.sh -f $FLAGS -r $REPOSITORY -t $TAG -h ${HEAP_SIZES[$heap_index]} -w $WARMUP -n $N -g $gc -b ${BENCHMARKS[$benchmark_index]} -i ${INPUT_WD}${INPUT_FILES[$benchmark_index]} -s $BATCH_SIZE -c ${CPUS[$heap_index]} > experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.out 2> experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.err
        done
    done
done

