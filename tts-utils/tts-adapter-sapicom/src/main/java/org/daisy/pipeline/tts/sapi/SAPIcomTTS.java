package org.daisy.pipeline.tts.sapi;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

import javax.sound.sampled.AudioFormat;

import org.concord.win.sapi53.ClassFactory;
import org.concord.win.sapi53.ISpeechFileStream;
import org.concord.win.sapi53.ISpeechObjectToken;
import org.concord.win.sapi53.ISpeechObjectTokens;
import org.concord.win.sapi53.ISpeechVoice;
import org.concord.win.sapi53.ISpeechWaveFormatEx;
import org.concord.win.sapi53.SpeechStreamFileMode;
import org.concord.win.sapi53.SpeechVoiceSpeakFlags;
import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.MarkFreeTTSService;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.Voice;

public class SAPIcomTTS extends MarkFreeTTSService {
	private AudioFormat mAudioFormat = null;
	private List<Voice> mAvailableVoices;
	private SSMLAdapter mSSMLAdapter;

	static private class ThreadResource extends TTSResource {
		ISpeechVoice voice;
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
	public TTSResource allocateThreadResources() throws SynthesisException {
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
	public int getOverallPriority() {
		return 1;
	}

	@Override
	public List<Voice> getAvailableVoices() throws SynthesisException {
		return mAvailableVoices;
	}

	@Override
	public void initialize() throws SynthesisException {
		mSSMLAdapter = new BasicSSMLAdapter() {
			@Override
			public String getHeader(String voiceName) {
				return "<speak version=\"1.0\" xmlns=\"http://www.w3.org/2001/10/synthesis\">";
			}

			@Override
			public String getFooter() {
				return super.getFooter() + "</speak>";
			}
		};

		//retrieve the name of the available voices
		ISpeechVoice v = ClassFactory.createSpVoice();
		mAvailableVoices = new ArrayList<Voice>();
		ISpeechObjectTokens allTokens = v.getVoices("", "");
		for (int i = 0; i < allTokens.count(); i++) {
			ISpeechObjectToken token = allTokens.item(i);
			String vendor = token.getAttribute("vendor");
			String name = token.getAttribute("name");
			if (vendor != null && name != null && !vendor.isEmpty() && !name.isEmpty()) {
				mAvailableVoices.add(new Voice(vendor, name));

			}
		}
		v.dispose();

		//test the TTS Service before registration
		ThreadResource th = (ThreadResource) allocateThreadResources();
		List<RawAudioBuffer> li = new ArrayList<RawAudioBuffer>();
		synthesize(mSSMLAdapter.getHeader(null) + "<s>test<break time=\"10ms\"/></s>"
		        + mSSMLAdapter.getFooter(), mAvailableVoices.get(0), th, li);
		releaseThreadResources(th);
		if (li.get(0).offsetInOutput <= 500) {
			throw new SynthesisException("SAPI with com4j did not output audio.");
		}
	}

	@Override
	public SSMLAdapter getSSMLAdapter() {
		return mSSMLAdapter;
	}

	@Override
	public void synthesize(String ssml, Voice voice, Object threadResources,
	        List<RawAudioBuffer> results) throws SynthesisException {
		ThreadResource th = (ThreadResource) threadResources;

		File dest;
		try {
			dest = File.createTempFile("sapi", ".wav");
			dest.deleteOnExit();
		} catch (IOException e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		ISpeechFileStream stream = ClassFactory.createSpFileStream();
		stream.open(dest.getAbsolutePath(), SpeechStreamFileMode.SSFMCreateForWrite, false);
		th.voice.audioOutputStream(stream);

		if (mAudioFormat == null) { //assuming there is a single-threaded testing call first
			ISpeechWaveFormatEx format = stream.format().getWaveFormatEx();
			mAudioFormat = new AudioFormat(format.samplesPerSec(), format.bitsPerSample(),
			        format.channels(), true, false);
		}

		th.voice.speak(ssml, SpeechVoiceSpeakFlags.SVSFParseSsml);
		th.voice.waitUntilDone(-1);

		stream.close();
		stream.dispose();

		RawAudioBuffer b = new RawAudioBuffer();
		b.offsetInOutput = 0;

		try {
			SoundUtil.readWave(dest, b);
		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		results.add(b);
	}

	@Override
	public void release() {
		mAudioFormat = null;
		mAvailableVoices = null;
		mSSMLAdapter = null;
		super.release();
	}
}
