package org.daisy.pipeline.tts;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

public interface TTSService {

	class SynthesisException extends Exception {
		public SynthesisException(String message, Throwable cause) {
			super(message, cause);
		}
	}

	public static class RawAudioBuffer {
		public byte[] output;
		public int offsetInOutput;
	};

	/**
	 * Must be thread safe because there is only one Synthesizer instantiated.
	 * 
	 * @param ssml is the SSML to synthesize. You may need to convert it to the
	 *            format understandable for the TTS (e.g SAPI) and your SSML
	 *            must include the <break time=".."/> at the end.
	 * @param output is the resulting raw audio data
	 * @param offsetInOutput is the position in bytes where the audio will be
	 *            written
	 * @param caller can be used to ensure data synchronization
	 * @return the array where the audio samples have been written to. If @param
	 *         output is big enough, it will return @output, otherwise it will
	 *         either returns null because there would be enough room if
	 *         offsetInOutput = 0, or a new dynamically-allocated array.
	 */
	Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer, Object caller,
	        Object memory) throws SynthesisException;

	/**
	 * @return the audio format (sample rate etc...) of the data produced by
	 *         synthesize(). The synthesizer is assumed to use the same audio
	 *         format every time.
	 */
	AudioFormat getAudioOutputFormat();

	/**
	 * @return the same name as in the CSS voice-family property. If several TTS
	 *         services share the same name, then the one with the highest
	 *         priority will be chosen.
	 */
	public String getName();

	public int getPriority(String lang);

}
