package org.daisy.pipeline.tts;

public class SoundUtil {

	static public void realloc(AudioBuffer buffer, int extra) {
		byte[] newBuffer = new byte[buffer.size + extra];
		System.arraycopy(buffer.data, 0, newBuffer, 0, buffer.size);
		buffer.data = newBuffer;
	}

	static public void cancelFootPrint(Iterable<AudioBuffer> buffers,
	        AudioBufferAllocator allocator) {
		for (AudioBuffer buff : buffers) {
			allocator.releaseBuffer(buff);
		}
	}
}
