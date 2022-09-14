package benchmark;

import java.io.FileWriter;

public class Sleep implements Benchmark {
    private static final String name = "sleep";

    public String getName() {
        return name;
    }

    public void execute(int n, FileWriter file, String[] args) throws Exception {
        for (int i = 0; i < n; i++) {
            System.gc();

            System.out.println("Execution " + i);
            long start = System.currentTimeMillis();
            sleep.Main.main(args);
            long end = System.currentTimeMillis();
            long duration = end - start;

            file.write(String.format("%s,%s,%s,%s,%s\n", this.getName(), i, start, end, duration));
        }
    }

}
