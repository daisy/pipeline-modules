package org.daisy.pipeline.tts.attnative;

import java.nio.ByteBuffer;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.LoadBalancer.Host;
import org.daisy.pipeline.tts.RoundRobinLoadBalancer;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.TTSService;

public class ATTNative implements TTSService, ATTLibListener {

	private AudioFormat mAudioFormat;
	private RoundRobinLoadBalancer mLoadBalancer;

	public static SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public String getFooter() {
			return "</voice>";
		}

		@Override
		public String getHeader(String voiceName) {
			if (voiceName == null || voiceName.isEmpty()) {
				return "<voice>";
			}
			return "<voice name=\"" + voiceName + "\">";
		}
	};

	private static class ThreadResource {
		long connection;
		RawAudioBuffer audioBuffer;
		int firstOffset;
		List<Map.Entry<String, Integer>> marks;
		byte[] utf8text;
	}

	public void initialize() throws SynthesisException {
		mLoadBalancer = new RoundRobinLoadBalancer(System.getProperty("att.servers",
		        "localhost:8888"), null);

		mAudioFormat = new AudioFormat(16000, 16, 1, true, false);
		System.loadLibrary("att");
		ATTLib.setListener(this);

		//Test the synthesizer so that the service won't be active if it fails.
		//It sets mAudioFormat too
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[16];
		Object r = allocateThreadResources();
		synthesize("test", new Voice(null, null), testBuffer, r, null);
		releaseThreadResources(r);
		if (testBuffer.output.length < 500) {
			throw new SynthesisException("ATT server(s) not working with att-sdk.");
		}
	}

	@Override
	public void synthesize(XdmNode ssml, Voice voice, RawAudioBuffer audioBuffer,
	        Object resource, List<Entry<String, Integer>> marks) throws SynthesisException {
		String str = SSMLUtil.toString(ssml, voice.name, mSSMLAdapter);
		synthesize(str, voice, audioBuffer, resource, marks);
	}

	private void synthesize(String ssml, Voice voice, RawAudioBuffer audioBuffer,
	        Object resource, List<Entry<String, Integer>> marks) throws SynthesisException {

		ThreadResource tr = (ThreadResource) resource;
		tr.audioBuffer = audioBuffer;
		tr.marks = marks;
		tr.firstOffset = tr.audioBuffer.offsetInOutput;

		UTF8Converter.UTF8Buffer utf8Buffer = UTF8Converter.convertToUTF8(ssml, tr.utf8text);
		tr.utf8text = utf8Buffer.buffer;

		ATTLib.speak(tr, tr.connection, tr.utf8text);
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return mAudioFormat;
	}

	@Override
	public String getName() {
		return "att";
	}

	@Override
	public void onRecvAudio(Object handler, ByteBuffer audio, int size) {
		ThreadResource tr = (ThreadResource) handler;
		if ((size + tr.audioBuffer.offsetInOutput) > tr.audioBuffer.output.length) {
			//reallocate because there is not enough room in the current buffer
			byte[] newBuffer = new byte[(3 * (tr.audioBuffer.offsetInOutput + size)) / 2];
			System.arraycopy(tr.audioBuffer.output, 0, newBuffer, 0,
			        tr.audioBuffer.offsetInOutput);
			tr.audioBuffer.output = newBuffer;

		}
		audio.get(tr.audioBuffer.output, tr.audioBuffer.offsetInOutput, size);
		tr.audioBuffer.offsetInOutput += size;
	}

	@Override
	public void onRecvMark(Object handler, String name) {
		ThreadResource tr = (ThreadResource) handler;
		tr.marks.add(new AbstractMap.SimpleEntry<String, Integer>(name,
		        tr.audioBuffer.offsetInOutput - tr.firstOffset));
	}

	@Override
	public Object allocateThreadResources() throws SynthesisException {
		Host h = mLoadBalancer.selectHost();
		long connection = ATTLib.openConnection(h.address, h.port, (int) mAudioFormat
		        .getSampleRate(), mAudioFormat.getSampleSizeInBits());
		if (connection == 0) {
			throw new SynthesisException("cannot open connections with ATTServer on "
			        + h.address + ":" + h.port, null);
		}

		ThreadResource tr = new ThreadResource();
		tr.connection = connection;
		tr.utf8text = new byte[8];
		return tr;
	}

	@Override
	public void releaseThreadResources(Object resource) {
		ThreadResource tr = (ThreadResource) resource;
		ATTLib.closeConnection(tr.connection);
	}

	@Override
	public String getVersion() {
		return "sdk";
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
		return Integer.valueOf(System.getProperty("att.native.priority", "10"));
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException {
		ThreadResource tr = (ThreadResource) allocateThreadResources();
		String[] voices = ATTLib.getVoiceNames(tr.connection);
		ATTLib.closeConnection(tr.connection);

		Voice[] result = new Voice[voices.length];
		for (int i = 0; i < voices.length; ++i) {
			result[i] = new Voice(getName(), voices[i]);
		}

		return Arrays.asList(result);
	}
}
