package org.daisy.pipeline.tts.att;

import java.io.File;
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

import net.sf.saxon.s9api.QName;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.BinaryFinder;
import org.daisy.pipeline.tts.LoadBalancer.Host;
import org.daisy.pipeline.tts.RoundRobinLoadBalancer;
import org.daisy.pipeline.tts.SSMLAdapter;
import org.daisy.pipeline.tts.SSMLUtil;
import org.daisy.pipeline.tts.SoundUtil;
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
	private int mSampleRate;
	private Pattern mMarkPattern;
	private RoundRobinLoadBalancer mLoadBalancer;
	private int fileid = 0;

	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public String getFooter() {
			return "</voice>";
		}

		@Override
		public String getHeader(String voiceName) {
			return "<voice name=\"" + voiceName + "\">";
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

	public ATTBin() throws SynthesisException {

		mLoadBalancer = new RoundRobinLoadBalancer(System.getProperty(
		        "att.servers", "localhost:8888"), null);

		mSampleRate = 16000;
		mAudioFormat = new AudioFormat(mSampleRate, 16, 1, true, false);

		final String property = "att.client.path";
		mATTPath = BinaryFinder.find(property, "TTSClientFile");
		if (mATTPath == null) {
			throw new SynthesisException(
			        "Cannot find AT&T's client in PATH and " + property
			                + " is not set");
		}

		mMarkPattern = Pattern.compile("([0-9]+)\\s+BOOKMARK:\\s+([^\\s]+)",
		        Pattern.MULTILINE);

		//test the synthesizer so that the service won't be active if it fails
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[2048];
		synthesize("x", testBuffer, mLoadBalancer.selectHost(), null,
		        new LinkedList<Map.Entry<String, Double>>(), 1);
	}

	@Override
	public Object synthesize(XdmNode ssml, Voice voice,
	        RawAudioBuffer audioBuffer, Object resources,
	        Object lastCallMemory, List<Entry<String, Double>> marks)
	        throws SynthesisException {
		return synthesize(SSMLUtil.toString(ssml, voice.name, mSSMLAdapter),
		        audioBuffer, resources, lastCallMemory, marks, 0);

	}

	private Object synthesize(String ssml, RawAudioBuffer audioBuffer,
	        Object resources, Object lastCallMemory,
	        List<Entry<String, Double>> marks, int tries)
	        throws SynthesisException {

		Host h = (Host) resources;
		File dest;
		if (lastCallMemory != null) {
			dest = (File) lastCallMemory;
		} else {
			try {
				dest = File.createTempFile("attbin", ".wav");
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			ssml.toString();

			String[] cmd = null;
			try {
				cmd = new String[]{
				        mATTPath, "-ssml", "-v0", "-s", h.address, "-p",
				        String.valueOf(h.port), "-r",
				        String.valueOf(mSampleRate), "-o",
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
		}

		// read the audio data from the resulting WAV file
		try {
			SoundUtil.readWave(dest, audioBuffer, false);
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
	public Object allocateThreadResources() {
		return mLoadBalancer.selectHost();
	}

	@Override
	public void releaseThreadResources(Object resource) {
	}

	@Override
	public String getVersion() {
		return "command-line";
	}

	@Override
	public void beforeAllocatingResources() {
		// TODO Auto-generated method stub

	}

	@Override
	public void afterAllocatingResources() {
		// TODO Auto-generated method stub

	}

	@Override
	public void beforeReleasingResources() {
		// TODO Auto-generated method stub

	}

	@Override
	public void afterReleasingResources() {
		// TODO Auto-generated method stub

	}

	@Override
	public int getOverallPriority() {
		return Integer.valueOf(System.getProperty("att.bin.priority", "5"));
	}

	@Override
	public List<Voice> getAvailableVoices() {
		// TODO Auto-generated method stub
		return null;
	}
}
