FROM ubuntu:20.04

RUN apt update
RUN apt install -y maven
RUN apt install -y git
RUN apt install -y ffmpeg

ENV OWNER_REPO="Gabrielgtt/serverless-memory-benchmark"

ADD https://api.github.com/repos/$OWNER_REPO/git/refs/heads/main /.git-hashref
RUN git clone https://github.com/$OWNER_REPO.git

ENV ORCHESTRATOR_PATH="serverless-memory-benchmark/Orchestrator"
WORKDIR ${ORCHESTRATOR_PATH}

RUN seq 1 99 | xargs -I XXX ffmpeg -i videos/video.mp4 -bsf:v noise=XXX videos/videoXXX.mp4
RUN mvn install -f pom.xml

RUN cp target/Orchestrator-1.0-SNAPSHOT-jar-with-dependencies.jar ./Orchestrator.jar
