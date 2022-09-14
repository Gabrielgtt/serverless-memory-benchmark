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
