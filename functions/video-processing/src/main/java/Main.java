import videoprocessing.*;

public class Main {

    public static void main(String[] args) throws Exception {
        int duration = 0;
        String videoPath = "";
        String operation = "";

        String usage = "Usage:\tjava Main.java [-v videoPath] [-d duration] [-o operation]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-v".equals(args[i])){
                videoPath = args[i+1];
                i++;
            } else if ("-o".equals(args[i])){
                operation = args[i+1];
                i++;
            } else if ("-d".equals(args[i])){
                duration = Integer.parseInt(args[i+1]);
                i++;
            } else {
                System.out.println("Unknown flag " + args[i]);
                System.out.println(usage);
                System.exit(0);
            }
        }

        Request req = new Request(videoPath,duration,operation);
        App app = new App();

        Response res = app.handler(req);

        System.out.println(res.processTime);
    }
}
