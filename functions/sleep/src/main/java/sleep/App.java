package sleep;

import java.util.concurrent.TimeUnit;

class Request {

    int sleepTime;

    public Request(int sleepTime){
        this.sleepTime = sleepTime;
    }

}

class Response {

    int sleepTime;

    public Response(int sleepTime){
        this.sleepTime = sleepTime;
    }

}

public class App {
    public Response handler(Request request) throws InterruptedException {
    	int sleepTime = request.sleepTime;
    	
        TimeUnit.SECONDS.sleep(sleepTime);

        return new Response(sleepTime);
    }
}
