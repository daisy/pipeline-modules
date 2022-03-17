package org.daisy.pipeline.tts;

public class AudioBuffer {
	protected AudioBuffer() {
		// must be allocated in subclasses
	}
	public byte[] data;
	/**
	 * Actual length of the audio data may be less than the allocated memory.
	 */
	public int size;
}
