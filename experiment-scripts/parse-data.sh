#!/bin/bash/

while getopts r:g:p: flag
do
    case "${flag}" in
        r) RUNS=${OPTARG};;
        g) GC=${OPTARG};;
        p) PATH_PATTERN=${OPTARG};;
    esac
done

seq 1 $RUNS | sudo xargs -I XXX python3 ../gc-parser/main.py -g $GC -l ${PATH_PATTERN}XXX/gc.log -i ${PATH_PATTERN}XXX/processed
