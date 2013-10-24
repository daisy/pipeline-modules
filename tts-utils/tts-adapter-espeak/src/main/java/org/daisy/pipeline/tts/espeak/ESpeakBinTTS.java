package org.daisy.pipeline.tts.espeak;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;
import java.util.List;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.BinaryFinder;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSService;

/**
 * This synthesizer uses directly the eSpeak binary and intermediate WAV files.
 */
public class ESpeakBinTTS implements TTSService {
	private AudioFormat mAudioFormat;
	private String mEspeakPath;
	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public QName adaptElement(QName elementName) {
			if (elementName.getLocalName().equals("mark"))
				return null;
			return new QName(null, elementName.getLocalName());
		}

		@Override
		public QName adaptAttributeName(QName element, QName attrName,
		        String value) {
			if (attrName.getLocalName().equals("lang")) {
				return attrName;
			}
			if (element.getLocalName().equals("s"))
				return null;
			return new QName(null, attrName.getLocalName());
		}
	};

	public ESpeakBinTTS() throws SynthesisException {
		mAudioFormat = new AudioFormat(22050, 16, 1, true, false);
		final String property = "espeak.client.path";
		mEspeakPath = BinaryFinder.find(property, "espeak");

		if (mEspeakPath == null) {
			throw new SynthesisException("Cannot find eSpeak's binary and "
			        + property + " is not set");
		}

		//test the synthesizer so that the service won't be active if it fails
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[1];
		Object r = allocateThreadResources();
		synthesize("x", testBuffer, r, null, null);
		releaseThreadResources(r);
	}

	@Override
	public Object synthesize(XdmNode ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {
		return synthesize(SSMLUtil.toString(ssml, voice.name, mSSMLAdapter),
		        audioBuffer, resource, lastCallMemory, marks);
	}

	private Object synthesize(String ssml, RawAudioBuffer audioBuffer,
	        Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {

		File dest = (File) resource;
		String[] cmd = null;
		try {
			// '-m' tells to interpret the input as SSML
			// '-w' tells to dump the result to a WAV file
			cmd = new String[]{
			        mEspeakPath, "-m", "-w", dest.getAbsolutePath(),
			        "\"" + ssml + "\""
			};
			Runtime.getRuntime().exec(cmd).waitFor();
		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		// read the audio data from the resulting WAV file
		try {
			boolean tryAgain = !SoundUtil.readWave(dest, audioBuffer, true);
			if (tryAgain)
				return Boolean.valueOf(true);
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
		return "espeak";
	}

	@Override
	public Object allocateThreadResources() throws SynthesisException {
		try {
			return File.createTempFile("espeak", ".wav");
		} catch (IOException e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}
	}

	@Override
	public void releaseThreadResources(Object resource) {
		File f = (File) resource;
		f.delete();
	}

	@Override
	public String getVersion() {
		return "command-line";
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
		return Integer.valueOf(System.getProperty("espeak.bin.priority", "1"));
	}

	@Override
	public List<Voice> getAvailableVoices() throws SynthesisException {
		//TODO: call the binary
		return Arrays.asList(new Voice[]{
		        new Voice(getName(), "en"), new Voice(getName(), "fr")
		});
	}
}
