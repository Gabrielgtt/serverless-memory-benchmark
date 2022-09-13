package thumbnailer;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

import javax.imageio.ImageIO;

import net.coobird.thumbnailator.Thumbnails;

public class App {

	//String inputBucket, outputBucket, key;
	
	public Response handler(Request request) throws IOException {
		
		//S3 storage = new S3(event.accessKey, event.secretAccessKey, event.region);
		Local storage = new Local();
		
//		this.inputBucket = event.inputBucket;
//		this.outputBucket = event.outputBucket;
//		this.key = event.key;
		
		//Open image
		LocalDateTime downloadBegin = LocalDateTime.now();
		File file = storage.open(request.filepath);
		BufferedImage image = ImageIO.read(file);
		LocalDateTime downloadEnd = LocalDateTime.now();
		
		//Resize image
		LocalDateTime processBegin = LocalDateTime.now();
		BufferedImage resized = Thumbnails.of(image).forceSize(request.width, request.height).asBufferedImage();
		LocalDateTime processEnd = LocalDateTime.now();
		
		//Save image
		LocalDateTime uploadBegin = LocalDateTime.now();
		long resizedSize = storage.save(resized,request.dest);
		LocalDateTime uploadEnd = LocalDateTime.now();
		
		long fetchTime = ChronoUnit.MILLIS.between(downloadBegin, downloadEnd);
		long saveTime = ChronoUnit.MILLIS.between(uploadBegin, uploadEnd);
		long processTime = ChronoUnit.MILLIS.between(processBegin, processEnd);
		
		return new Response(fetchTime,saveTime,processTime, resizedSize, file.length());
	}
}
