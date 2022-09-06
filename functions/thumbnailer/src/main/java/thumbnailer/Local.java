package thumbnailer;

import java.awt.image.BufferedImage;
import java.io.File;
import java.io.IOException;

import javax.imageio.ImageIO;

public class Local {

	public File open(String filepath) throws IOException {
		
		File file = new File(filepath);
		
		return file;
	}

	public long save(BufferedImage image, String dest) throws IOException {
		
		File outputFile = new File(dest);
		ImageIO.write(image, "jpg", outputFile);
		
		return outputFile.length();
	}

}
