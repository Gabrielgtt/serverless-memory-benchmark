package videoprocessing;

public class Request {
    int duration;
    String videopath;
    String op;

    public Request(String videopath, int duration, String op) {
        this.duration = duration;
        this.videopath = videopath;
        this.op = op;
    }
}
