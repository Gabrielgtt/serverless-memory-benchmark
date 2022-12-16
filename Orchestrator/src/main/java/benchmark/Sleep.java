package benchmark;

import java.io.FileWriter;
import java.lang.Runtime;

public class Sleep implements Benchmark {

    private static final String name = "sleep";

    public String getName() {
        return name;
    }

    public void execute(int n, int batch_size, FileWriter file, String[] args) throws Exception {
        Runtime rt = Runtime.getRuntime();
        for (int j = 0; j < n; j++) {
            System.gc();

            for (int i = 0; i < batch_size; i++) {
                System.out.println("Execution " + i);
                long free_before = rt.freeMemory();
                long start = System.currentTimeMillis();

                sleep.Main.main(args);

                long free_after = rt.freeMemory();
                long allocated = (free_before - free_after);
                long end = System.currentTimeMillis();
                long duration = end - start;

                file.write(String.format("%s,%s,%s,%s,%s,%s\n", this.getName(), i, start, end, duration, allocated));
            }
        }
    }

}
