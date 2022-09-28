#!/bin/bash/

while getopts r:t:h:w:n:g:b:i: flag
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
    esac
done

CONTAINERID=$(sudo docker run -it -d $REPOSITORY:$TAG)
CONTAINER_WD=$(sudo docker inspect --format='{{.Config.WorkingDir}}' $CONTAINERID)

echo $CONTAINERID

execute_benchmark() {
    exp_tag=$1
    gc_log_fp="${CONTAINER_WD}/${exp_tag}.log"

    sudo docker cp $INPUT_FILE ${CONTAINERID}:${CONTAINER_WD}/input.json

    sudo docker exec $CONTAINERID bash -c \
        "rm -rf ${gc_log_fp}*"

    sudo docker exec $CONTAINERID bash -c \
        "java -XX:+Use${GC}GC -Xlog:gc:file=${gc_log_fp}:uptime,tags,level:filecount=1,filesize=6g -Xms${HEAP_SIZE} -Xmx${HEAP_SIZE} -cp Orchestrator.jar Main -b $BENCHMARK -i input.json -n $WARMUP"
}

collect_results() {
    exp_tag=$1
    gc_log_fp="${CONTAINER_WD}/${exp_tag}.log"

    mkdir ./$exp_tag/

    sudo docker cp ${CONTAINERID}:${CONTAINER_WD}/results ./${exp_tag}/results
    sudo docker cp ${CONTAINERID}:${gc_log_fp} ./${exp_tag}/gc.log
}

kill_container() {
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
        exit 1
    fi

    echo_line
    echo "Running $exp_tag" 
    execute_benchmark $exp_tag

    echo "Collecting results"
    collect_results $exp_tag

    echo "Killing container"
    kill_container
done
