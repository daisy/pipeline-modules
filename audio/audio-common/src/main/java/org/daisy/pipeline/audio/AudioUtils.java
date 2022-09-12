package org.daisy.pipeline.audio;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.util.Iterator;
import java.util.NoSuchElementException;
import java.io.IOException;

import com.google.common.io.ByteStreams;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

public final class AudioUtils {

	private AudioUtils() {}

	/**
	 * Create an {@link AudioInputStream} from an {@link AudioFormat} and the audio data.
	 *
	 * @param format Expected to be PCM.
	 */
	public static AudioInputStream createAudioStream(AudioFormat format, byte[] data) {
		return createAudioStream(format, new ByteArrayInputStream(data));
	}

	public static AudioInputStream createAudioStream(AudioFormat format, ByteArrayInputStream data) {
		if (format.getFrameSize() == AudioSystem.NOT_SPECIFIED)
			throw new IllegalArgumentException("unknown frame size");
		return new AudioInputStream(data,
		                            format,
		                            // ByteArrayInputStream.available() returns
		                            // the total number of bytes
		                            data.available() / format.getFrameSize());
	}

	/**
	 * Create a {@link AudioInputStream} from a {@link InputStream}.
	 *
	 * This is to work around a bug in {@link javax.sound.sampled.AudioSystem}
	 * which may return {@link AudioInputStream} with a wrong {@link
	 * AudioInputStream#getFrameLength()}.
	 */
	public static AudioInputStream createAudioStream(InputStream stream)
			throws UnsupportedAudioFileException, IOException {
		AudioInputStream audio = AudioSystem.getAudioInputStream(new BufferedInputStream(stream));
		AudioFormat format = audio.getFormat();
		if (format.getFrameSize() != AudioSystem.NOT_SPECIFIED) {
			byte[] data = ByteStreams.toByteArray(audio);
			audio.close();
			audio = createAudioStream(format, data);
		}
		return audio;
	}

	/**
	 * Concatenate a sequence of {@link AudioInputStream} into a single {@link AudioInputStream}.
	 *
	 * @param streams Must be streams with the same (PCM) audio format.
	 */
	public static AudioInputStream concat(Iterable<AudioInputStream> streams) {
		int count = 0;
		long _totalLength = 0;
		AudioFormat format = null;
		for (AudioInputStream s : streams) {
			count++;
			_totalLength += s.getFrameLength();
			if (format == null) {
				format = s.getFormat();
				if (!isPCM(format))
					throw new IllegalArgumentException("AudioInputStream must be PCM encoded, but got: "+ format);
				if (format.getFrameSize() == AudioSystem.NOT_SPECIFIED)
					throw new IllegalArgumentException();
			} else if (!format.matches(s.getFormat()))
				throw new IllegalArgumentException("Can not concatenate AudioInputStream with different audio formats");
		}
		if (count == 0)
			throw new IllegalArgumentException("At least one AudioInputStream expected");
		if (count == 1)
			return streams.iterator().next();
		long totalLength = _totalLength;
		int frameSize = format.getFrameSize();
		return new AudioInputStream(
			new InputStream() {
				Iterator<AudioInputStream> nextStreams = streams.iterator();
				AudioInputStream stream = null;
				byte[] frame = new byte[frameSize];
				long availableFrames = totalLength;
				int availableInFrame = 0;
				public int read() throws IOException {
					if (availableFrames == 0 && availableInFrame == 0)
						return -1;
					if (availableInFrame > 0)
						return frame[frameSize - (availableInFrame--)] & 0xFF;
					if (stream != null) {
						availableInFrame = stream.read(frame);
						if (availableInFrame > 0) {
							availableFrames--;
							return frame[frameSize - (availableInFrame--)] & 0xFF;
						}
					}
					try {
						if (stream != null)
							stream.close();
						stream = nextStreams.next();
					} catch (NoSuchElementException e) {
						return -1;
					}
					return read();
				}
				public int available() {
					try {
						return Math.toIntExact(Math.multiplyExact(availableFrames, frameSize)) + availableInFrame;
					} catch (ArithmeticException e) {
						return Integer.MAX_VALUE;
					}
				}
				public void close() throws IOException {
					if (stream != null)
						stream.close();
					while (nextStreams.hasNext())
						nextStreams.next().close();
				}
			},
			format,
			totalLength);
	}

	/**
	 * Convert audio from one format to another.
	 */
	public static AudioInputStream convertAudioStream(AudioFormat newFormat, AudioInputStream stream) {
		return AudioSystem.getAudioInputStream(newFormat, stream);
	}

	public static boolean isPCM(AudioFormat format) {
		Encoding encoding = format.getEncoding();
		return encoding == Encoding.PCM_SIGNED
			|| encoding == Encoding.PCM_UNSIGNED
			|| encoding == Encoding.PCM_FLOAT;
	}
}
