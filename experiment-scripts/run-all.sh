#!/bin/bash/

source ./vars.env

if [ ! -d "output" ]; then
    mkdir "output"
fi

for heap_index in ${!HEAP_SIZES[@]}; do
    for gc in ${GCS[@]}; do
        for benchmark_index in ${!BENCHMARKS[@]}; do
            sudo bash run.sh -r gc -t latest -h ${HEAP_SIZES[$heap_index]} -w $WARMUP -n $N -g $gc -b ${BENCHMARKS[$benchmark_index]} -i ${INPUT_WD}${INPUT_FILES[$benchmark_index]} -s $BATCH_SIZE -c ${CPUS[$heap_index]} -d ${EXP_DATE}> output/experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.out 2> output/experiment-$gc-${BENCHMARKS[$benchmark_index]}-${HEAP_SIZES[$heap_index]}.err
        done
    done
done

