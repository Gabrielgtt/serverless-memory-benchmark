## Dependencies

1. Install [Docker](https://docs.docker.com/engine/install/ubuntu/)

## Build image

```bash
sudo docker build --tag $REPOSITORY:$TAG --file docker/Dockerfile .
```

## Create container and get container ID

```bash
GCID=$(sudo docker run -it -d $REPOSITORY:$TAG)
```

## Create your input file and copy to container

```bash
sudo docker cp input.json $GCID:$(sudo docker inspect --format='{{.Config.WorkingDir}}' $GCID)/input.json
```

## Execute your benchmark

```bash
sudo docker exec $GCID bash -c "java -cp Orchestrator.jar Main [-b benchmark] [-i input] [-n iterations]"
```

## Collect results

```bash
sudo docker cp $GCID:$(sudo docker inspect --format='{{.Config.WorkingDir}}' $GCID)/results ./results
```