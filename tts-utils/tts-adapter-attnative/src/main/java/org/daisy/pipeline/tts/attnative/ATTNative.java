package org.daisy.pipeline.tts.attnative;

import java.nio.ByteBuffer;
import java.util.AbstractMap;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.QName;
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

	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public String getFooter() {
			return "</voice>";
		}

		@Override
		public String getHeader(String voiceName) {
			if (voiceName == null || voiceName.isEmpty()) {
				return "<voice>";
			}
			return "<voice name=\"" + voiceName + "\"/>";
		}

		@Override
		public QName adaptElement(QName elementName) {
			return new QName(null, elementName.getLocalName());
		}

		@Override
		public QName adaptAttributeName(QName element, QName attrName,
		        final String value) {
			if (attrName.getLocalName().equals("lang")) {
				return attrName;
			}
			if (element.getLocalName().equals("s"))
				return null;
			return new QName(null, attrName.getLocalName());
		}

		@Override
		public String adaptAttributeValue(QName element, QName attrName,
		        String value) {
			if (attrName.getLocalName().equals("lang") && !value.contains("_")) {
				value = value.replaceAll("[^0-9a-zA-Z]+", "_");
				if (!value.contains("_")) {
					if (value.equals("en"))
						value = value.concat("_us");
					else
						value = value.concat("_" + value); //e.g 'fr' => 'fr_fr'
				}
			}
			return value;
		}
	};

	private static class ThreadResource {
		long connection;
		RawAudioBuffer audioBuffer;
		int firstOffset;
		List<Map.Entry<String, Double>> marks;
	}

	public void initialize() throws SynthesisException {
		mLoadBalancer = new RoundRobinLoadBalancer(System.getProperty(
		        "att.servers", "localhost:8888"), null);

		mAudioFormat = new AudioFormat(16000, 16, 1, true, false);
		System.loadLibrary("att");
		ATTLib.setListener(this);
	}

	@Override
	public Object synthesize(XdmNode ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {

		ThreadResource tr = (ThreadResource) resource;
		tr.audioBuffer = audioBuffer;
		tr.marks = marks;
		tr.firstOffset = tr.audioBuffer.offsetInOutput;

		ATTLib.synthesizeRequest(tr, tr.connection,
		        SSMLUtil.toString(ssml, voice.name, mSSMLAdapter));

		return null;
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
		double time = (double) ((tr.audioBuffer.offsetInOutput - tr.firstOffset) / (mAudioFormat
		        .getFrameRate() * mAudioFormat.getFrameSize()));
		tr.marks.add(new AbstractMap.SimpleEntry<String, Double>(name, time));
	}

	@Override
	public Object allocateThreadResources() throws SynthesisException {
		Host h = mLoadBalancer.selectHost();
		long connection = ATTLib.openConnection(h.address, h.port,
		        (int) mAudioFormat.getSampleRate(),
		        mAudioFormat.getSampleSizeInBits());
		if (connection == 0) {
			throw new SynthesisException(
			        "cannot open connections with ATTServer on " + h.address
			                + ":" + h.port, null);
		}

		ThreadResource tr = new ThreadResource();
		tr.connection = connection;
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
