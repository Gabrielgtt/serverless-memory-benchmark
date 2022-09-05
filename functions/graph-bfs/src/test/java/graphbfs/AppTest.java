package graphbfs;

import org.junit.Assert;
import org.junit.Test;

public class AppTest {

	@Test
	public void testBFS() {
		
		int numberVertex = 10;
		
		Request req = new Request(numberVertex);
		
		App a = new App();
		
		Response res = a.handler(req);
		
		System.out.println(res.visitedVertex.size() + " | " + res.generateTime + " | " + res.processTime);
		System.out.println(res.visitedVertex);
		
		Assert.assertEquals(res.visitedVertex.size(), numberVertex);
	}
	
}
