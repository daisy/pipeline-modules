package org.daisy.pipeline.tts.sapi;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.concord.win.sapi53.ClassFactory;
import org.concord.win.sapi53.ISpeechFileStream;
import org.concord.win.sapi53.ISpeechObjectToken;
import org.concord.win.sapi53.ISpeechObjectTokens;
import org.concord.win.sapi53.ISpeechVoice;
import org.concord.win.sapi53.ISpeechWaveFormatEx;
import org.concord.win.sapi53.SpeechStreamFileMode;
import org.concord.win.sapi53.SpeechVoiceSpeakFlags;
import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSService;

public class SAPIcomTTS implements TTSService {
	private AudioFormat mAudioFormat = null;
	private List<Voice> mAvailableVoices;
	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public QName adaptElement(QName elementName) {
			if (elementName.getLocalName().equals("token"))
				return null;
			return new QName(null, elementName.getLocalName());
		}

		@Override
		public QName adaptAttributeName(QName element, QName attrName,
		        final String value) {
			if (element.getLocalName().equals("s"))
				return null;
			return new QName(null, attrName.getLocalName());
		}

		@Override
		public String getHeader(String voiceName) {
			return "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\">";
		}

		@Override
		public String getFooter() {
			return "</speak>";
		}
	};

	static private class ThreadResource {
		ISpeechVoice voice;
	}

	@Override
	public Object synthesize(XdmNode ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {
		return synthesize(SSMLUtil.toString(ssml, voice.name, mSSMLAdapter),
		        voice, audioBuffer, resource, lastCallMemory, marks);
	}

	private Object synthesize(String ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {

		ThreadResource th = (ThreadResource) resource;

		File dest;
		try {
			dest = File.createTempFile("sapi", ".wav");
			dest.deleteOnExit();
		} catch (IOException e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}


		ISpeechFileStream stream = ClassFactory.createSpFileStream();
		stream.open(dest.getAbsolutePath(),
		        SpeechStreamFileMode.SSFMCreateForWrite, false);
		th.voice.audioOutputStream(stream);

		if (mAudioFormat == null) { //assuming there is a single-threaded testing call first
			ISpeechWaveFormatEx format = stream.format().getWaveFormatEx();
			mAudioFormat = new AudioFormat(format.samplesPerSec(),
			        format.bitsPerSample(), format.channels(), true, false);
		}

		th.voice.speak(ssml, SpeechVoiceSpeakFlags.SVSFParseSsml);
		th.voice.waitUntilDone(-1);

		stream.close();
		stream.dispose();

		try {
			SoundUtil.readWave(dest, audioBuffer, false);
		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		return null;
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
		ThreadResource th = new ThreadResource();
		th.voice = ClassFactory.createSpVoice();
		return th;
	}

	@Override
	public void releaseThreadResources(Object resource) {
		ThreadResource th = (ThreadResource) resource;
		th.voice.dispose();
	}

	@Override
	public String getVersion() {
		return "com4j";
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
		return 1;
	}

	@Override
	public List<Voice> getAvailableVoices() throws SynthesisException {
		return mAvailableVoices;
	}
	
	@Override
    public void initialize() throws SynthesisException {
		//retrieve the name of the available voices
		ISpeechVoice v = ClassFactory.createSpVoice();
		mAvailableVoices = new ArrayList<Voice>();
		ISpeechObjectTokens allTokens = v.getVoices("", "");
		for (int i = 0; i < allTokens.count(); i++) {
			ISpeechObjectToken token = allTokens.item(i);
			String vendor = token.getAttribute("vendor");
			String name = token.getAttribute("name");
			if (vendor != null && name != null && !vendor.isEmpty()
					&& !name.isEmpty()) {
				mAvailableVoices.add(new Voice(vendor, name));
			
			}
		}
		v.dispose();

		//test the TTS Service before registration
		ThreadResource th = (ThreadResource) allocateThreadResources();
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[1];
		synthesize(
				mSSMLAdapter.getHeader(null)
						+ "<s>test<break time=\"10ms\"></break></s>"
						+ mSSMLAdapter.getFooter(),
				mAvailableVoices.get(0), testBuffer, th, null, null);
		releaseThreadResources(th);
		if (testBuffer.offsetInOutput <= 0) {
			throw new SynthesisException(
					"SAPI with com4j did not output anything.");
		}
    }
}
