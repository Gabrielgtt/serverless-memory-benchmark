package thumbnailer;

public class Response {
    public long fetchTime, saveTime, processTime, resizedSize, originalSize;

    public Response(long fetchTime, long saveTime, long processTime, long resizedSize, long originalSize) {
        this.fetchTime = fetchTime;
        this.processTime = processTime;
        this.saveTime = saveTime;
        this.resizedSize = resizedSize;
        this.originalSize = originalSize;
    }
}
