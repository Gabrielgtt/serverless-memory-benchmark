package benchmark;

import java.io.FileWriter;

public interface Benchmark {

    public String getName();
    public void execute(int n, FileWriter file, String[] args) throws Exception;

}
