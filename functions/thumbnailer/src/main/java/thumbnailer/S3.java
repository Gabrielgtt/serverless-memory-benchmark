package thumbnailer;

import java.io.InputStream;

import com.amazonaws.auth.AWSCredentials;
import com.amazonaws.auth.AWSStaticCredentialsProvider;
import com.amazonaws.auth.BasicAWSCredentials;
import com.amazonaws.services.s3.model.PutObjectResult;
import com.amazonaws.services.s3.AmazonS3;
import com.amazonaws.services.s3.AmazonS3ClientBuilder;
import com.amazonaws.services.s3.model.ObjectMetadata;
import com.amazonaws.services.s3.model.S3Object;
import com.amazonaws.services.s3.model.S3ObjectInputStream;

public class S3 {

	private AmazonS3 s3client;
	
	public S3(String accessKey, String secretAccessKey, String region) {
		AWSCredentials credentials = new BasicAWSCredentials(accessKey,secretAccessKey);
		
		this.s3client = AmazonS3ClientBuilder.standard()
		.withCredentials(new AWSStaticCredentialsProvider(credentials))
		.withRegion(region)
		.build();
	}

	public AmazonS3 getS3client() {
		return s3client;
	}
	
	public S3ObjectInputStream fetch(String bucket, String key) {
		
		S3Object s3object = s3client.getObject(bucket, key);
		
		S3ObjectInputStream inputStream = s3object.getObjectContent();
		
		return inputStream;
	}
	
	public String save(String bucket, String key, InputStream resized) {
		
		ObjectMetadata metadata = new ObjectMetadata();
		
		PutObjectResult s3object = s3client.putObject(bucket, key, resized, metadata);
		
		return key;
	}
}
