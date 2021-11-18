package org.daisy.pipeline.audio;

import java.io.File;
import java.util.Optional;

import javax.sound.sampled.AudioFormat;

public interface AudioEncoder {

	/**
	 * Encode raw audio data into a single file (mp3 for instance). This method
	 * must forward any exceptions (including InterruptionException).
	 *
	 * @param pcm are the audio data. The method is allowed to modify the audio
	 *            buffers (both their content and their size).
	 *
	 * @param audioFormat tells how the data must be interpreted
	 *
	 * @param outputDir is the directory where the sound file will be stored
	 *
	 * @param filePrefix is the prefix of the output sound filename.
	 *
	 * @return the URI where the sound has been output. The extension (e.g.
	 *         'mp3') is up to the encoder. Returns an absent optional if an
	 *         error occurs that cannot be easily transformed into a throwable
	 *         exception.
	 * @throws Throwable
	 */
	Optional<String> encode(Iterable<AudioBuffer> pcm, AudioFormat audioFormat,
	                        File outputDir, String filePrefix) throws Throwable;

}

