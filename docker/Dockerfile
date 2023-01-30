FROM ubuntu:20.04

RUN apt update
RUN apt install -y maven
RUN apt install -y git
RUN apt install -y ffmpeg

RUN git clone https://github.com/Gabrielgtt/serverless-memory-benchmark/
ENV ORCHESTRATOR_PATH="serverless-memory-benchmark/Orchestrator"

WORKDIR ${ORCHESTRATOR_PATH}

RUN seq 1 99 | xargs -I XXX cp videos/video.mp4 videos/videoXXX.mp4
RUN mvn install -f pom.xml

RUN cp target/Orchestrator-1.0-SNAPSHOT-jar-with-dependencies.jar ./Orchestrator.jar
