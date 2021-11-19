import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.util.Map;
import java.util.Optional;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioInputStream;

import org.daisy.pipeline.audio.AudioEncoder;
import org.daisy.pipeline.audio.AudioEncoderService;
import static org.daisy.pipeline.audio.AudioFileTypes.MP3;

import org.ops4j.pax.exam.util.PathUtils;

import org.osgi.service.component.annotations.Component;

@Component(
	name = "mock-encoder",
	service = { AudioEncoderService.class }
)
public class MockEncoder implements AudioEncoderService {
	
	private final static File mp3 = new File(PathUtils.getBaseDir(), "src/test/resources/mock-encoder/mock.mp3");
	
	public boolean supportsFileType(AudioFileFormat.Type fileType) {
		return MP3.equals(fileType);
	}
	
	public Optional<AudioEncoder> newEncoder(Map<String,String> params) {
		return Optional.of(
			new AudioEncoder() {
				@Override
				public void encode(AudioInputStream pcm, AudioFileFormat.Type fileType, File outputFile) throws Throwable {
					if (!MP3.equals(fileType))
						throw new IllegalArgumentException();
					outputFile.getParentFile().mkdirs();
					outputFile.createNewFile();
					FileInputStream reader = new FileInputStream(mp3);
					FileOutputStream writer = new FileOutputStream(outputFile);
					byte[] buffer = new byte[153600];
					int bytesRead = 0;
					while ((bytesRead = reader.read(buffer)) > 0) {
						writer.write(buffer, 0, bytesRead);
						buffer = new byte[153600]; }
					writer.close();
					reader.close();
				}
			}
		);
	};
}
