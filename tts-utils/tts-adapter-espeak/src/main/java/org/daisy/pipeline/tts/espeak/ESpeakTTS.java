package org.daisy.pipeline.tts.espeak;

import java.util.List;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.TTSService;

public class ESpeakTTS implements TTSService {

	@Override
	public AudioFormat getAudioOutputFormat() {
		return null;
	}

	@Override
	public String getName() {
		return "espeak";
	}

	@Override
	public int getPriority(String lang) {
		return -100;
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object resource, Object memory, List<Entry<String, Double>> marks)
	        throws SynthesisException {
		return null;
	}

	@Override
	public Object allocateThreadResources() {
		return null;
	}

	@Override
	public void releaseThreadResources(Object resource) {
	}

	@Override
	public String getVersion() {
		return null;
	}

}
