package sleep;

import java.util.concurrent.TimeUnit;

public class App {
    public Response handler(Request request) throws InterruptedException {
    	int sleepTime = request.sleepTime;
    	
        TimeUnit.SECONDS.sleep(sleepTime);

        return new Response(sleepTime);
    }
}
