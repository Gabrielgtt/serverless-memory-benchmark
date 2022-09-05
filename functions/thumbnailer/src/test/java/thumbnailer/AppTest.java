package thumbnailer;

import java.io.IOException;

import org.junit.Assert;
import org.junit.Test;

public class AppTest {

	@Test
	public void testResizeImage() throws IOException {
		
		Request req = new Request("sundown.jpeg", "resized.jpg", 500, 500);
		
		App a = new App();
		
		Response res = a.handler(req);
		
		System.out.println(res.fetchTime + " | " + res.processTime + " | " + res.processTime + " | " + res.originalSize + " | " + res.resizedSize);
		
		Assert.assertTrue(res.fetchTime > 0);
		Assert.assertTrue(res.saveTime > 0);
		Assert.assertTrue(res.processTime > 0);
		Assert.assertTrue(res.originalSize > res.resizedSize);
	}
	
}
