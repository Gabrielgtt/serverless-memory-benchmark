package graphbfs;

public class Main {

    public static void main(String[] args) throws Exception {
        int graphSize = 0;

        String usage = "Usage:\tjava Main.java [-size graphSize]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-size".equals(args[i])){
                graphSize = Integer.parseInt(args[i+1]);
                i++;
            } else {
                System.out.println("Unknown flag " + args[i]);
                System.out.println(usage);
                System.exit(0);
            }
        }

        Request req = new Request(graphSize);
        App app = new App();

        Response res = app.handler(req);
    }
}
