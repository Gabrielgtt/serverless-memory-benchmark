#!/bin/bash/

set -x

DATE_TODAY=$(date +'%d-%m')

while getopts r:t:h:w:n:g:b:i:s:c:f: flag
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
                f) FLAGS=${OPTARG};;
        esac
done

read -r -d '' EXP_DESCRITION << EOM
    Heap size = $HEAP_SIZE\nWarmup runs = $WARMUP\nNumber of repetitions = $N\nGc = $GC\nBenchmark (function name) = $BENCHMARK\nInput file = $INPUT_FILE\nBatch size = $BATCH_SIZE\nNumber of CPU cores = $CPU\nJVM Flags = $FLAGS
EOM

bash discord-bot.sh -m "!! EXPERIMENT STARTING !!" -t "exp-$DATE_TODAY: $(date)" -d "$EXP_DESCRITION" -s ok

echo "CAREFUL! We are using hard-coded 21g docker container memory!!"
CONTAINERID=$(sudo docker run -it -d --cpus="${CPU}" --memory="21g" $REPOSITORY:$TAG)


if [ $? -eq 0 ]; then
        echo "OK"
        bash discord-bot.sh -m "Container created" -t "exp-$DATE_TODAY" -d "Começamos bem!" -s ok
else
        ERROR_MSG="Error while running docker run. See .err file"
        bash discord-bot.sh -m "Container failed" -t "exp-$DATE_TODAY" -d "$ERROR_MSG" -s error
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
                "java ${FLAGS} -XX:+Use${GC}GC -Xlog:gc:file=${gc_log_fp}:uptime,tags,level:filecount=1,filesize=6g -Xms${HEAP_SIZE} -Xmx${HEAP_SIZE} -cp Orchestrator.jar Main -b $BENCHMARK -i input.json -n $WARMUP -s ${BATCH_SIZE} > orchestrator.out 2> orchestrator.err"
}

collect_results() {
        echo "Collecting results"
        exp_tag=$1
        gc_log_fp="${CONTAINER_WD}/${exp_tag}.log"

        mkdir ./$exp_tag/

        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/results ./${exp_tag}/results
        sudo docker cp ${CONTAINERID}:${gc_log_fp} ./${exp_tag}/gc.log
        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/orchestrator.out ./${exp_tag}/orchestrator.out
        sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/orchestrator.err ./${exp_tag}/orchestrator.err
}

kill_container() {
    echo "Killing container"
    sudo docker kill $CONTAINERID
    sudo docker rm $CONTAINERID
}

compress_output() {
    trunc_cpu="${CPU/\.*/}c"
    exp_tag=exp-${GC}-${BENCHMARK}-${HEAP_SIZE}${trunc_cpu}
    zip_fp=exp-$DATE_TODAY.zip
    zip -r $zip_fp ${exp_tag}*
}

echo_line() {
        for i in $(seq 1 $(tput cols)); do echo -n '='; done
        echo ""
}


for exp in $(seq 1 $N);
do
        trunc_cpu="${CPU/\.*/}c"
        exp_tag=exp-${GC}-${BENCHMARK}-${HEAP_SIZE}${trunc_cpu}-${exp}

        if [[ -d $exp_tag ]]
        then
                ERROR_MSG="Directory $exp_tag already exists"
                echo $ERROR_MSG
                bash discord-bot.sh -m "Experiment stopped:" -t "exp-$DATE_TODAY" -d "$ERROR_MSG" -s error
                kill_container
                exit 1
        fi

        echo_line
        execute_benchmark $exp_tag

        collect_results $exp_tag
done

compress_output

bash discord-bot.sh -m "Experiment finished!" -t "exp-$DATE_TODAY" -d "Tudo certo pelo visto!" -s ok

kill_container

