package org.daisy.pipeline.tts.sapinative;

import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSService;

public class SAPINative implements TTSService {

	private AudioFormat mAudioFormat;

	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public String getHeader(String voiceName) {
			return "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\">";
		}

		@Override
		public String getFooter() {
			return super.getFooter() + "</speak>";
		}
	};

	private static class ThreadResource {
		long connection;
	}

	public void initialize() throws SynthesisException {
		System.loadLibrary("sapinative");
		SAPILib.initialize(Integer.valueOf(System.getProperty("sapi.samplerate", "22050")),
		        Integer.valueOf(System.getProperty("sapi.bitspersample", "16")));
	}

	@Override
	public void synthesize(XdmNode ssml, Voice voice, RawAudioBuffer audioBuffer,
	        Object resource, List<Entry<String, Integer>> marks, boolean retry)
	        throws SynthesisException {

		ThreadResource tr = (ThreadResource) resource;

		SAPILib.speak(tr.connection, voice.name, voice.vendor, SSMLUtil.toString(ssml,
		        voice.name, mSSMLAdapter));

		int size = SAPILib.getStreamSize(tr.connection);
		if (size > (audioBuffer.output.length - audioBuffer.offsetInOutput)) {
			SoundUtil.realloc(audioBuffer, size);
		}

		SAPILib.readStream(tr.connection, audioBuffer.output, audioBuffer.offsetInOutput);
		audioBuffer.offsetInOutput += size;

		String[] names = SAPILib.getBookmarkNames(tr.connection);
		long[] pos = SAPILib.getBookmarkPositions(tr.connection);

		for (int i = 0; i < names.length; ++i) {
			marks.add(new AbstractMap.SimpleEntry<String, Integer>(names[i], (int) pos[i]));
		}
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return mAudioFormat;
	}

	@Override
	public String getName() {
		return "sapi";
	}

	@Override
	public Object allocateThreadResources() throws SynthesisException {
		long connection = SAPILib.openConnection();

		if (connection == 0) {
			throw new SynthesisException("cannot initialize voices for SAPI native version");
		}

		ThreadResource tr = new ThreadResource();
		tr.connection = connection;
		return tr;
	}

	@Override
	public void releaseThreadResources(Object resource) {
		ThreadResource tr = (ThreadResource) resource;
		SAPILib.closeConnection(tr.connection);
	}

	@Override
	public String getVersion() {
		return "native";
	}

	@Override
	public void beforeAllocatingResources() throws SynthesisException {
	}

	@Override
	public void afterAllocatingResources() throws SynthesisException {
	}

	@Override
	public void beforeReleasingResources() throws SynthesisException {
	}

	@Override
	public void afterReleasingResources() throws SynthesisException {
	}

	@Override
	public int getOverallPriority() {
		return Integer.valueOf(System.getProperty("sapi.native.priority", "2"));
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException {
		String[] names = SAPILib.getVoiceNames();
		String[] vendors = SAPILib.getVoiceVendors();
		List<Voice> voices = new ArrayList<Voice>();
		for (int i = 0; i < names.length; ++i) {
			voices.add(new Voice(vendors[i], names[i]));
		}
		return voices;
	}

	public void deactivate() {
		SAPILib.dispose();
	}

	@Override
	public String endingMark() {
		return "ending-mark";
	}
}
