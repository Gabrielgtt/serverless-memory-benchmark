package factorial;

public class Main {

    public static void main(String[] args) throws Exception {
        int n = 0;

        String usage = "Usage:\tjava Main.java [-n n]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-n".equals(args[i])) {
                n = Integer.parseInt(args[i+1]);
                i++;
            } else {
                System.out.println("Unknown flag " + args[i]);
                System.out.println(usage);
                System.exit(0);
            }
        }

        Request req = new Request(n);
        App app = new App();

        Response res = app.handler(req);
    }

}
