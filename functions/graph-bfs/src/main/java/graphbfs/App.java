package graphbfs;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Random;
import java.util.function.Supplier;

import org.jgrapht.Graph;
import org.jgrapht.generate.BarabasiAlbertGraphGenerator;
import org.jgrapht.graph.DefaultDirectedGraph;
import org.jgrapht.graph.DefaultEdge;
import org.jgrapht.graph.SimpleDirectedGraph;
import org.jgrapht.graph.SimpleGraph;
import org.jgrapht.traverse.BreadthFirstIterator;
import org.jgrapht.util.SupplierUtil;

class Request {
	int size;
	
	Request(int size) {
		this.size = size;
	}
}

class Response {
	List<Integer> visitedVertex;
	long generateTime, processTime;
	
	Response(List<Integer> visitedVertex, long generateTime, long processTime) {
		this.visitedVertex = visitedVertex;
		this.generateTime = generateTime;
		this.processTime = processTime;
	}
}

public class App {
	
	private List<Integer> bfs(Graph<Integer, DefaultEdge> graph, int vertex) {
		
		BreadthFirstIterator<Integer, DefaultEdge> iterator = new BreadthFirstIterator<>(graph, 0);
		
		List<Integer> visitedVertex = new ArrayList<Integer>();
		
		while(iterator.hasNext()) {
			int v = iterator.next();
			visitedVertex.add(v);
		}
		
		return visitedVertex;
	}

	public Response handler(Request request) {
		
		LocalDateTime graphGenerateBegin = LocalDateTime.now();
		Supplier<Integer> vSupplier = new Supplier<Integer>()
        {
            private int id = 0;

            @Override
            public Integer get()
            {
                return id++;
            }
        };
		Graph<Integer, DefaultEdge> graph = new DefaultDirectedGraph<>(vSupplier, SupplierUtil.createDefaultEdgeSupplier(), false);
		BarabasiAlbertGraphGenerator<Integer, DefaultEdge> generator = new BarabasiAlbertGraphGenerator<>(request.size, 10, request.size);
		generator.generateGraph(graph);
		LocalDateTime graphGenerateEnd = LocalDateTime.now();
		
		LocalDateTime processBegin = LocalDateTime.now();
		List<Integer> visitedVertex = bfs(graph, 0);
		LocalDateTime processEnd = LocalDateTime.now();
		
		long generateTime = ChronoUnit.MILLIS.between(graphGenerateBegin, graphGenerateEnd);
		long processTime = ChronoUnit.MILLIS.between(processBegin, processEnd);
		
		return new Response(visitedVertex, generateTime, processTime);
	}
	
}
