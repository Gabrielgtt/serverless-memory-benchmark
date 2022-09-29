package benchmark;

import java.io.FileWriter;

public class Sleep implements Benchmark {
    private static final String name = "sleep";

    public String getName() {
        return name;
    }

    public void execute(int n, int batch_size, FileWriter file, String[] args) throws Exception {
        for (int j = 0; j < batch_size; j++) {
            System.gc();

            for (int i = 0; i < n; i++) {
                System.out.println("Execution " + i);
                long start = System.currentTimeMillis();
                sleep.Main.main(args);
                long end = System.currentTimeMillis();
                long duration = end - start;

                file.write(String.format("%s,%s,%s,%s,%s\n", this.getName(), i, start, end, duration));
            }
        }
    }

}
