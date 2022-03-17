package org.daisy.pipeline.audio;

import javax.sound.sampled.AudioFileFormat;

/**
 * Supported audio file types
 */
public final class AudioFileTypes {

	public static final AudioFileFormat.Type MP3 = new AudioFileFormat.Type("MP3", "mp3");
	public static final AudioFileFormat.Type WAVE = AudioFileFormat.Type.WAVE;

}