package videoprocessing;

public class Request {
    int duration;
    String videoPath;
    String op;

    public Request(String videoPath, int duration, String op) {
        this.duration = duration;
        this.videoPath = videoPath;
        this.op = op;
    }
}
