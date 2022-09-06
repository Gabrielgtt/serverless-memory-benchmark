package sleep;

import org.junit.Test;
import org.junit.Assert;

public class AppTest {

	@Test
    public void testSleep() throws InterruptedException
    {
    	
    	int sleepTime = 5;
    	
    	Request req = new Request(sleepTime);
    	
        App a = new App();

        Response res = a.handler(req);

        Assert.assertEquals(res.sleepTime, sleepTime);
    }
}
