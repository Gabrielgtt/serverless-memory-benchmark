#!/bin/bash

SKIP=true

while getopts s: flag
do
        case "${flag}" in
                s) SKIP=${OPTARG};;
        esac
done

if [ $SKIP = true ]
then
    echo "Deu certo"
fi
