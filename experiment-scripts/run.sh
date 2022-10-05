#!/bin/bash/

set -x

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

echo $CPU
echo $FLAGS

CONTAINERID=$(sudo docker run -it -d --cpus="${CPU}" --memory="${HEAP_SIZE}" $REPOSITORY:$TAG)
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

echo_line() {
        for i in $(seq 1 $(tput cols)); do echo -n '='; done
        echo ""
}

for exp in $(seq 1 $N);
do
        exp_tag=exp-${GC}-${BENCHMARK}-${exp}

        if [[ -d $exp_tag ]]
        then
                echo "ERROR: Directory $exp_tag already exists"
                kill_container
                exit 1
        fi

        echo_line
        execute_benchmark $exp_tag

        collect_results $exp_tag
done


kill_container

