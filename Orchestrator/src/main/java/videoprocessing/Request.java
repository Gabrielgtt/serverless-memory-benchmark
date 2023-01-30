package videoprocessing;

public class Request {
    int duration;
    String videpPath;
    String op;

    public Request(String videpPath, int duration, String op) {
        this.duration = duration;
        this.videpPath = videpPath;
        this.op = op;
    }
}
