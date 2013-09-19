package org.daisy.pipeline.tts.att;

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.TTSService;

/**
 * This synthesizer uses directly the AT&T's client binary and intermediate WAV
 * files.
 * 
 * Before any conversion, run $HOME/ATT/bin/TTSServer -m 40 -c {mPort} -config
 * your-tts-conf.cfg
 */
public class LinuxATT4 implements TTSService {
	private AudioFormat mAudioFormat;
	private String mATTPath;
	private int mPort;
	private int mSampleRate;
	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
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

	//TODO: read the path, the port and the audio format from a configuration file
	public LinuxATT4() {
		mSampleRate = 16000;
		mAudioFormat = new AudioFormat(mSampleRate, 16, 1, true, false);
		mPort = 8888;
		mATTPath = System.getProperty("user.home") + "/ATT/bin/TTSClientFile";
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object caller, Object lastCallMemory) throws SynthesisException {

		File dest;
		if (lastCallMemory != null) {
			dest = (File) lastCallMemory;
		} else {
			try {
				dest = File.createTempFile("att",
				        Long.toString(System.nanoTime()));
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			ssml.toString();

			String[] cmd = null;
			try {
				cmd = new String[]{
				        mATTPath, "-ssml", "-v0", "-p", String.valueOf(mPort),
				        "-r", String.valueOf(mSampleRate), "-o",
				        dest.getAbsolutePath()
				};
				Process p = Runtime.getRuntime().exec(cmd);
				//TODO: deal with SSML longer than 500 bytes
				p.getOutputStream()
				        .write(SSMLUtil.toString(ssml, mSSMLAdapter).getBytes(
				                "UTF-8"));
				p.getOutputStream().close();
				p.waitFor();
			} catch (Exception e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			if (dest.length() > audioBuffer.output.length) {
				// the audio is not big enough => dynamic allocation
				audioBuffer.output = new byte[(int) dest.length()];
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
			if (e.getMessage() == null)
				throw new SynthesisException(e.getClass().getSimpleName(),
				        e.getCause());
			else
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
		return "att";
	}

	@Override
	public int getPriority(String lang) {
		if (lang == null) {
			return 1;
		}

		if (lang.startsWith("en")) {
			return 3;
		}
		return 1;
	}
}
