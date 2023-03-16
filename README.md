# serverless-memory-benchmark

A benchmark for serverless-like functions that includes metrics of memory allocation.

## How this repository is organized

- **docker**: Contains the Dockerfile for the application and instructions on how to run it.
- **experiment-analysis**: Contains R scripts to process data from benchmark executions.
- **experiments-scripts**: Contains bash scripts that automate installation of dependencies, building and running the benchmark.
- **gc-parser**: Contains parsers for GC logs of differente GCs.
- **inputs**: Contains the inputs for each functions on the benchmark.
- **Orchestrator**: Contains the code for each function and the code that orchestrates their execution.


## How to run a benchmark

The benchmark is written in Java and built with maven, but we use docker to containerize it. Everything you need to run to execute a benchmark is on **experiment-scripts**. Go to the **experiment-scripts** directory and run the following steps from there:

1. Build the docker image.
```shell 
bash build.sh
```

If you already have docker installed in your machine, skip the installation.
```shell 
bash build.sh -s true
```

After this a new image of 921Mb should have been created with the repository "gc" and tag "latest".

2. Set the parameters of your experiment. Create a copy of vars-template.env with the name `vars.env` and edit the variables as pleased. You do not need to set a discord webhook url, but if you want to be notified when the experiments ends via a discord bot, you can do it. For a test experiment, try reducing all parameters to have only one level, i.e., one GC, one Heap configuration, one vCPU configuration, one repetition etc.
```shell
cp vars-template.env vars.env
nano vars.env
```

3. Run the benchmark. 
```shell
bash run-all.sh
```

If you are running on a remote machine, you can in background and monitor the benchmark logs. All logs are written in the same directory where the scripts were executed.
```shell
bash run-all.sh &
```

4. Collect the results. The output is stored in directories created in the same directory where the scripts were executed. You will find logs from the GC, logs from docker and a results file with the execution time and allocated memory for each function call.


## Benchmarks

### sleep

Sleeps for _size_ seconds. 
```json
{ "size": 1 }
```

### dynamic-html

Generate dynamic HTML from a template.
```json
{
    "user": "test",
    "lenght": 100000
}
```

### graph-bfs

Breadth-first search (BFS) implementation.
```json
{
    "size": 2500
}
```

### thumbnailer

Generate a thumbnail of an image.
```json
{
    "width": 200,
    "height": 200,
    "destPath": "resized.jpg",
    "filePath": "sundown.jpeg"
}
```

### video-processing

Add a watermark and generate gif of a video file.
```json
{
    "dirpath": "videos/",
    "duration": 3,
    "operation": "extract-gif"
}
```

### fibonacci
```json
{
    "n": 100
}
```


### factorial
```json
{
    "n": 100
}
```
