package org.daisy.pipeline.tts.espeak;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Map.Entry;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.BinaryFinder;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.TTSService;


/**
 * This synthesizer uses directly the espeak binary and intermediate WAV files.
 */
public class ESpeakBinTTS implements TTSService {
	private static int MinRiffHeaderSize = 44;
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
		testBuffer.output = new byte[2048];
		synthesize("x", testBuffer, null, null, null);
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {
		return synthesize(SSMLUtil.toString(ssml, mSSMLAdapter), audioBuffer,
		        resource, lastCallMemory, marks);
	}

	private Object synthesize(String ssml, RawAudioBuffer audioBuffer,
	        Object resource, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {

		File dest;
		if (lastCallMemory != null) {
			dest = (File) lastCallMemory;
		} else {
			try {
				dest = File.createTempFile("espeak",
				        Long.toString(System.nanoTime()));
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

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

			int maxLength = (int) (dest.length() - MinRiffHeaderSize);
			if (maxLength > audioBuffer.output.length) {
				// the audio is not big enough => dynamic allocation
				audioBuffer.output = new byte[(int) maxLength];
				audioBuffer.offsetInOutput = 0;
			} else if (dest.length() > (audioBuffer.output.length - audioBuffer.offsetInOutput)) {
				// the audio buffer is big enough but it needs to be flushed
				return dest;
			}
		}

		// read the audio data from the resulting WAV file
		try {
			AudioInputStream fi = AudioSystem.getAudioInputStream(dest);
			int read = 0;
			while (audioBuffer.offsetInOutput + read != audioBuffer.output.length
			        && read != -1) {
				audioBuffer.offsetInOutput += read;
				read = fi.read(audioBuffer.output, audioBuffer.offsetInOutput,
				        audioBuffer.output.length - audioBuffer.offsetInOutput);
			}
			fi.close();
		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		} finally {
			dest.delete();
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
	public int getPriority(String lang) {
		if (lang == null) {
			return 1;
		}

		if (lang.startsWith("en")) {
			return 2;
		}
		return 1;
	}

	@Override
	public Object allocateThreadResources() {
		//no resource attached
		return null;
	}

	@Override
	public void releaseThreadResources(Object resource) {
	}

	@Override
	public String getVersion() {
		return "command-line";
	}
}
