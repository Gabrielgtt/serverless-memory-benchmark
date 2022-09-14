package videoprocessing;

import java.io.IOException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.HashMap;
import java.util.Map;

interface Runner {
	public String run(String video, int duration) throws IOException;
}

public class App {
	
	private Map<String,Runner> operations;
	
	public App() {
		operations = new HashMap<String, Runner>();
		operations.put("extract-gif", new Runner() {
			public String run(String video, int duration) throws IOException {
				return toGif(video, duration);
			}
		});
		operations.put("watermark", new Runner() {
			public String run(String video, int duration) throws IOException {
				return watermark(video,duration);
			}
		});
	}
	
	public String toGif(String video, int duration) throws IOException {
		Runtime rt = Runtime.getRuntime();
		String output = "processed-gif.gif";
		
		String command = String.format("ffmpeg -i %s -t %d -vf fps=10,scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse -loop 0 %s", video, duration, output);
		
		System.out.println(command);
		
		Process pr = rt.exec(command);
		
		return output;
	}
	
	public String watermark(String video, int duration) throws IOException {
		Runtime rt = Runtime.getRuntime();
		String watermark = "watermark.png";
		String output = "processed-watermark.mp4";
		
		String command = String.format("ffmpeg -i %s -i %s -t %d -filter_complex overlay=main_w/2-overlay_w/2:main_h/2-overlay_h/2 %s", video, watermark, duration, output);
		
		Process pr = rt.exec(command);
		
		return output;
	}
	
	

	public Response handler(Request request) throws IOException {
		
		LocalDateTime processBegin = LocalDateTime.now();
		String outputPath = this.operations.get(request.op).run(request.videoPath, request.duration);
		LocalDateTime processEnd = LocalDateTime.now();
		
		long processTime = ChronoUnit.MILLIS.between(processBegin, processEnd);
		
		return new Response(processTime);
	}
	
}
