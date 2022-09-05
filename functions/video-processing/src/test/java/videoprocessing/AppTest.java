package videoprocessing;

import java.io.IOException;

import org.junit.Assert;
import org.junit.Test;


public class AppTest {

	@Test
	public void videoProcessingTest() throws IOException {
		App a = new App();
		
		Request req = new Request("video.mp4", 5, "watermark");
		
		Response res = a.handler(req);
		
		Assert.assertTrue(res.processTime > 0);
	}
	
}
