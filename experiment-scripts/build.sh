#!/bin/bash

SKIP_DOCKER_INSTALL=false

while getopts s: flag
do
    case "${flag}" in
        s) SKIP_DOCKER_INSTALL=${OPTARG};;
    esac
done


if [ $SKIP_DOCKER_INSTALL == false ] 
then
    # Install Docker -------------------------------------------

    sudo apt update
    sudo apt install ca-certificates curl gnupg lsb-release

    sudo mkdir -p /etc/apt/keyrings

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update

    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin

    sudo service docker start
fi


# Build the Benchmark's Docker image -----------------------

# Entering the root folder of the project ------------------
cd ..
sudo docker build --tag gc:latest --file docker/Dockerfile .

