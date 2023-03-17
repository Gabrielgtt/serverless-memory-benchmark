#!/bin/bash/

set -x

EXP_DATE=$(date +'%d-%m')

while getopts r:t:h:w:n:g:b:i:s:c:d: flag
do
        case "${flag}" in
                r) REPOSITORY=${OPTARG};;
                t) TAG=${OPTARG};;
                h) HEAP_SIZE=${OPTARG};;
                w) WARMUP=${OPTARG};;
                n) N=${OPTARG};;
                g) GC=${OPTARG};;
                b) BENCHMARK=${OPTARG};;
                i) INPUT_FILE=${OPTARG};;
                s) BATCH_SIZE=${OPTARG};;
                c) CPU=${OPTARG};;
                d) EXP_DATE=${OPTARG};;
        esac
done

JVM_FLAGS=""

if [ $GC == "Epsilon" ] 
then
    JVM_FLAGS="-XX:+AlwaysPreTouch -XX:+UnlockExperimentalVMOptions"
fi

read -r -d '' EXP_DESCRITION << EOM
    Heap size = $HEAP_SIZE\nWarmup runs = $WARMUP\nNumber of repetitions = $N\nGc = $GC\nBenchmark (function name) = $BENCHMARK\nInput file = $INPUT_FILE\nBatch size = $BATCH_SIZE\nNumber of CPU cores = $CPU\nJVM Flags = $JVM_FLAGS
EOM

bash discord-bot.sh -m "!! EXPERIMENT STARTING !!" -t "exp-$EXP_DATE: $(date)" -d "$EXP_DESCRITION" -s ok

echo "CAREFUL! We are using hard-coded 21g docker container memory!!"
CONTAINERID=$(sudo docker run -it -d --cpus="${CPU}" --memory="21g" $REPOSITORY:$TAG)


if [ $? -eq 0 ]; then
        echo "OK"
        bash discord-bot.sh -m "Container created" -t "exp-$EXP_DATE" -d "Começamos bem!" -s ok
else
        ERROR_MSG="Error while running docker run. See .err file"
        bash discord-bot.sh -m "Container failed" -t "exp-$EXP_DATE" -d "$ERROR_MSG" -s error
        echo $ERROR_MSG
        exit $?
fi

CONTAINER_WD=$(sudo docker inspect --format='{{.Config.WorkingDir}}' $CONTAINERID)

execute_benchmark() {
        echo "Running $1"
        exp_tag=$1
        gc_log_fp="${CONTAINER_WD}/${exp_tag}.log"

        sudo docker cp $INPUT_FILE ${CONTAINERID}:${CONTAINER_WD}/input.json

        sudo docker exec $CONTAINERID bash -c \
                "rm -rf ${gc_log_fp}*"

        sudo docker exec $CONTAINERID bash -c \
                "java ${JVM_FLAGS} -XX:+Use${GC}GC -Xlog:gc:file=${gc_log_fp}:uptime,tags,level:filecount=1,filesize=6g -Xms${HEAP_SIZE} -Xmx${HEAP_SIZE} -cp Orchestrator.jar Main -b $BENCHMARK -i input.json -n $WARMUP -s ${BATCH_SIZE} > orchestrator.out 2> orchestrator.err"
}

collect_results() {
        echo "Collecting results"
        exp_tag=$1
        gc_log_fp="${CONTAINER_WD}/${exp_tag}.log"

        mkdir ./output/$exp_tag/

        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/results ./output/${exp_tag}/results
        sudo docker cp ${CONTAINERID}:${gc_log_fp} ./output/${exp_tag}/gc.log
        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/orchestrator.out ./output/${exp_tag}/orchestrator.out
        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/orchestrator.err ./output/${exp_tag}/orchestrator.err
}

kill_container() {
    echo "Killing container"
    sudo docker kill $CONTAINERID
    sudo docker rm $CONTAINERID
}

compress_output() {
    trunc_cpu="${CPU/\.*/}c"
    exp_tag=output/exp-${GC}-${BENCHMARK}-${HEAP_SIZE}${trunc_cpu}
    zip_fp=output/exp-$EXP_DATE.zip
    zip -r $zip_fp ${exp_tag}*
}


for exp in $(seq 1 $N);
do
        trunc_cpu="${CPU/\.*/}c"
        exp_tag=exp-${GC}-${BENCHMARK}-${HEAP_SIZE}${trunc_cpu}-${exp}

        exp_dir=output/$exp_tag
        if [[ -d $exp_dir ]]
        then
                ERROR_MSG="Directory $exp_dir already exists"
                echo $ERROR_MSG
                bash discord-bot.sh -m "Experiment stopped:" -t "exp-$EXP_DATE" -d "$ERROR_MSG" -s error
                kill_container
                exit 1
        fi

        echo "-----------------------------"

        execute_benchmark $exp_tag

        collect_results $exp_tag
done

compress_output

bash discord-bot.sh -m "Experiment finished!" -t "exp-$EXP_DATE" -d "Tudo certo pelo visto!" -s ok

kill_container

