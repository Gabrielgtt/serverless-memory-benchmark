import java.io.File;

public class Main {
    public static void main(String[] args) throws Exception {
        String benchmark = "", input = "";
        int iterations = 1;

        String usage = "Usage:\tjava Main.java [-b benchmark] [-i input] [-n iterations]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-b".equals(args[i])) {
                benchmark = args[i+1];
                i++;
            } else if ("-i".equals(args[i])) {
                input = args[i+1];
                i++;
            } else if ("-n".equals(args[i])) {
                iterations = Integer.parseInt(args[i+1]);
                i++;
            } else {
                throw new Exception("Unknown flag" + args[i] + "\n" + usage);
            }
        }

        new File("results").mkdir();

        switch (benchmark) {
            case "sleep":
                Orchestrator.sleep(input, iterations);
                break;
            case "dynamic-html":
                Orchestrator.dynamicHTML(input,iterations);
                break;
            case "graph-bfs":
                Orchestrator.graphBFS(input,iterations);
                break;
            case "thumbnailer":
                Orchestrator.thumbnailer(input,iterations);
                break;
            case "video-processing":
                Orchestrator.videoProcessing(input,iterations);
                break;
            case "fibonacci":
                Orchestrator.fibonacci(input,iterations);
                break;
            case "factorial":
                Orchestrator.factorial(input,iterations);
                break;
            default:
                throw new Exception("Unknown benchmark\n" + usage);
        }
    }

}
