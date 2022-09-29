package benchmark;

import java.io.FileWriter;

public interface Benchmark {

    public String getName();
    public void execute(int n, int batch_size, FileWriter file, String[] args) throws Exception;

}
