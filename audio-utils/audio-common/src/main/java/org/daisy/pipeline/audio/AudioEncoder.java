package org.daisy.pipeline.audio;

import java.io.File;

import javax.sound.sampled.AudioFormat;

public interface AudioEncoder {
	/**
	 * Encode raw audio data into a single file (mp3 for instance).
	 * 
	 * @param input are the audio data
	 * @param size is the number of bytes of 'input' to be encoded
	 * @param audioFormat tells how the data must be interpreted
	 * 
	 * @param caller is the Java object calling encode(). It can help making
	 *            multi-threading strategies.
	 * 
	 * @param outputDir is the directory where the sound file will be stored
	 * 
	 * @param filePrefix is the prefix of the name of the output sound file.
	 * 
	 * @return the URI where the sound has been output
	 */
	String encode(byte[] input, int size, AudioFormat audioFormat, Object caller,
	        File outputDir, String filePrefix);
}
