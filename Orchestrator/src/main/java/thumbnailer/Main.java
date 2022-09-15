package thumbnailer;

public class Main {

    public static void main(String[] args) throws Exception {
        String filepath = "";
        String dest = "";
        int width = 0, height = 0;

        String usage = "Usage:\tjava Main.java [-f filePath] [-d fileDest] [-w width] [-h height]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-f".equals(args[i])){
                filepath = args[i+1];
                i++;
            } else if ("-d".equals(args[i])){
                dest = args[i+1];
                i++;
            } else if ("-w".equals(args[i])){
                width = Integer.parseInt(args[i+1]);
                i++;
            } else if ("-h".equals(args[i])){
                height = Integer.parseInt(args[i+1]);
                i++;
            } else {
                System.out.println("Unknown flag " + args[i]);
                System.out.println(usage);
                System.exit(0);
            }
        }

        Request req = new Request(filepath,dest,width,height);
        App app = new App();

        Response res = app.handler(req);
    }
}
