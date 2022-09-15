package dynamichtml;

public class Main {

    public static void main(String[] args) throws Exception {
        int randomLen = 0;
        String username = "";

        String usage = "Usage:\tjava Main.java [-user username] [-len length]";
        if (args.length > 0 && ("-h".equals(args[0]) || "-help".equals(args[0]))) {
            System.out.println(usage);
            System.exit(0);
        }

        for (int i = 0; i < args.length; i++) {
            if ("-user".equals(args[i])) {
                username = args[i+1];
                i++;
            } else if ("-len".equals(args[i])){
                randomLen = Integer.parseInt(args[i+1]);
                i++;
            } else {
                System.out.println("Unknown flag " + args[i]);
                System.out.println(usage);
                System.exit(0);
            }
        }

        Request req = new Request(username, randomLen);
        App app = new App();

        Response res = app.handler(req);
    }
}
