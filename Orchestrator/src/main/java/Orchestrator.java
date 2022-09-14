import org.json.simple.JSONObject;
import org.json.simple.parser.JSONParser;
import sleep.*;

import java.io.*;

public class Orchestrator {
    private static final String SLEEP = "sleep";
    private static final String DYNAMICHTML = "dynamic-html";
    private static final String GRAPHBFS = "graph-bfs";
    private static final String THUMBNAILER = "thumbnailer";
    private static final String VIDEOPROCESSING = "video-processing";
    public static void sleep(String input, int n) throws Exception {
        JSONParser parser = new JSONParser();
        FileWriter file = new FileWriter("results/" + SLEEP + ".csv");
        file.write("benchmark,req_id,init_time,end_time,duration\n");

        Object obj = parser.parse(new FileReader(input));
        JSONObject jsonObject = (JSONObject) obj;
        Long size = (Long) jsonObject.get("size");
        System.out.println(size);

        String[] args = new String[]{"-s", String.valueOf(size)};

        for (int i = 0; i < n; i++) {
            System.gc();

            System.out.println("Execution " + i);
            long start = System.currentTimeMillis();
            sleep.Main.main(args);
            long end = System.currentTimeMillis();
            long duration = end - start;

            file.write(String.format("%s,%s,%s,%s,%s\n", SLEEP, i, start, end, duration));
        }

        file.close();
    }

}
