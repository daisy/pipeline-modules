package org.daisy.pipeline.audio;

import java.io.File;
import java.util.Optional;

import javax.sound.sampled.AudioInputStream;

public interface AudioEncoder {

	/**
	 * Encode raw audio data into a single file (mp3 for instance). This method
	 * must forward any exceptions (including InterruptionException).
	 *
	 * @param pcm is the raw input audio.
	 *
	 * @param outputDir is the directory where the sound file will be stored
	 *
	 * @param filePrefix is the prefix of the output sound filename.
	 *
	 * @return the URI where the sound has been output. The extension (e.g.
	 *         'mp3') is up to the encoder. Returns an absent optional if an
	 *         error occurs that cannot be easily transformed into a throwable
	 *         exception.
	 *
	 * @throws Throwable
	 */
	Optional<String> encode(AudioInputStream pcm, File outputDir, String filePrefix) throws Throwable;

}

