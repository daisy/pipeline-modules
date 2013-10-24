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
	public Object synthesize(XdmNode ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resource, Object memory,
	        List<Entry<String, Double>> marks) throws SynthesisException {
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

	@Override
	public void beforeAllocatingResources() throws SynthesisException {
		// TODO Auto-generated method stub

	}

	@Override
	public void afterAllocatingResources() throws SynthesisException {
		// TODO Auto-generated method stub

	}

	@Override
	public void beforeReleasingResources() throws SynthesisException {
		// TODO Auto-generated method stub

	}

	@Override
	public void afterReleasingResources() throws SynthesisException {
		// TODO Auto-generated method stub

	}

	@Override
	public int getOverallPriority() {
		// TODO Auto-generated method stub
		return 0;
	}

	@Override
	public List<Voice> getAvailableVoices() throws SynthesisException {
		// TODO Auto-generated method stub
		return null;
	}

}
