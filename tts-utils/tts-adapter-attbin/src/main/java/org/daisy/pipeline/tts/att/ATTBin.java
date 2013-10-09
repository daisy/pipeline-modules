package org.daisy.pipeline.tts.att;

import java.io.BufferedInputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.AbstractMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.regex.MatchResult;
import java.util.regex.Pattern;

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
public class ATTBin implements TTSService {
	private static int MinRiffHeaderSize = 44;
	private AudioFormat mAudioFormat;
	private String mATTPath;
	private int mPort;
	private int mSampleRate;
	private Pattern mMarkPattern;
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

	private int fileid = 0;

	private synchronized int getFileId() {
		++fileid;
		return fileid;
	}

	//TODO: read the path, the port and the audio format from a configuration file
	public ATTBin() throws SynthesisException {
		mSampleRate = 16000;
		mAudioFormat = new AudioFormat(mSampleRate, 16, 1, true, false);
		mPort = 8888;
		mATTPath = System.getProperty("user.home") + "/ATT/bin/TTSClientFile";
		mMarkPattern = Pattern.compile("([0-9]+)\\s+BOOKMARK:\\s+([^\\s]+)",
		        Pattern.MULTILINE);

		//test the synthesizer so that the service won't be active if it fails
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[2048];
		synthesize("x", testBuffer, null, null,
		        new LinkedList<Map.Entry<String, Double>>(), 1);
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object resources, Object lastCallMemory,
	        List<Entry<String, Double>> marks) throws SynthesisException {
		return synthesize(SSMLUtil.toString(ssml, mSSMLAdapter), audioBuffer,
		        resources, lastCallMemory, marks, 0);

	}

	private Object synthesize(String ssml, RawAudioBuffer audioBuffer,
	        Object resources, Object lastCallMemory,
	        List<Entry<String, Double>> marks, int tries)
	        throws SynthesisException {
		File dest;
		if (lastCallMemory != null) {
			dest = (File) lastCallMemory;
		} else {
			try {
				dest = File.createTempFile("attbin",
				        String.valueOf(getFileId()));
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
				p.getOutputStream().write(ssml.getBytes("UTF-8"));
				p.getOutputStream().close();

				InputStream is = p.getInputStream();
				Scanner scanner = new Scanner(is);
				while (scanner.findWithinHorizon(mMarkPattern, 0) != null) {
					MatchResult mr = scanner.match();
					double seconds = Double.valueOf(mr.group(1))
					        / mAudioFormat.getSampleRate();
					marks.add(new AbstractMap.SimpleEntry<String, Double>(mr
					        .group(2), seconds));
				}
				is.close();
				p.waitFor();
			} catch (Exception e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			int maxLength = (int) (dest.length() - MinRiffHeaderSize);
			if (maxLength > audioBuffer.output.length) {
				// the audio is not big enough => dynamic allocation
				audioBuffer.output = new byte[(int) maxLength];
				audioBuffer.offsetInOutput = 0;
			} else if (maxLength > (audioBuffer.output.length - audioBuffer.offsetInOutput)) {
				// the audio buffer is big enough but it needs to be flushed
				return dest;
			}
		}

		// read the audio data from the resulting WAV file
		try {
			AudioInputStream fi = AudioSystem
			        .getAudioInputStream(new BufferedInputStream(
			                new FileInputStream(dest)));
			int read = 0;
			while (read != -1) {
				audioBuffer.offsetInOutput += read;
				read = fi.read(audioBuffer.output, audioBuffer.offsetInOutput,
				        audioBuffer.output.length - audioBuffer.offsetInOutput);
			}
			fi.close();
		} catch (Exception e) {
			if (tries == 0) {
				marks.clear();
				return synthesize(ssml, audioBuffer, resources, lastCallMemory,
				        marks, tries + 1);
			} else if (e.getMessage() == null)
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
		} else if (lang.startsWith("fr")) {
			return 3;
		}
		return 1;
	}

	@Override
	public Object allocateThreadResources() {
		// no resource attached
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
