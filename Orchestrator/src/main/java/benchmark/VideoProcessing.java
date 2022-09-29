package benchmark;

import java.io.FileWriter;

public class VideoProcessing implements Benchmark {

    private static final String name = "video-processing";

    public String getName() {
        return name;
    }

    public void execute(int n, int batch_size, FileWriter file, String[] args) throws Exception {
        for (int j = 0; j < n; j++) {
            System.gc();

            for (int i = 0; i < batch_size; i++) {
                System.out.println("Execution " + i);
                long start = System.currentTimeMillis();
                videoprocessing.Main.main(args);
                long end = System.currentTimeMillis();
                long duration = end - start;

                file.write(String.format("%s,%s,%s,%s,%s\n", this.getName(), i, start, end, duration));
            }
        }
    }

}
