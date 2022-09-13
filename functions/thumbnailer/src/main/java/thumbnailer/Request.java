package thumbnailer;

public class Request {
    // String inputBucket, outputBucket, key, accessKey, secretAccessKey, region;
    int width, height;
    String filepath, dest;

    public Request(String filepath, String dest, int width, int height) {
        this.width = width;
        this.height = height;
        this.filepath = filepath;
        this.dest = dest;
    }
}
