package graphbfs;

import java.util.List;

public class Response {
    public List<Integer> visitedVertex;
    public long generateTime, processTime;

    public Response(List<Integer> visitedVertex, long generateTime, long processTime) {
        this.visitedVertex = visitedVertex;
        this.generateTime = generateTime;
        this.processTime = processTime;
    }
}
