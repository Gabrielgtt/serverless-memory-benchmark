# serverless-memory-benchmark
Codes for the research about improving automatic memory management on Serverless

## Build Orchestrator

Go to the `Orchestrator` directory
```bash
cd Orchestrator
```

Generate .jar file

```bash
sudo mvn package
```

## Execute

```bash
java -cp {jar-file} Main [-b benchmark] [-i input] [-n iterations]
```

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
    "destPath": resized.jpg,
    "filePath": sundown.jpeg
}
```

### video-processing

Add a watermark and generate gif of a video file.
```json
{
    "videoPath": video.mp4,
    "duration": 3,
    "operation": extract-gif
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
