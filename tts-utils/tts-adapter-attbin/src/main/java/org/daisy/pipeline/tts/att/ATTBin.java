package org.daisy.pipeline.tts.att;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.AbstractMap;
import java.util.Collection;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.Set;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
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
import org.daisy.pipeline.tts.TTSRegistry;
import org.daisy.pipeline.tts.TTSRegistry.VoiceInfo;
import org.daisy.pipeline.tts.TTSService;

/**
 * This synthesizer uses directly the AT&T's client binary and intermediate WAV
 * files.
 * 
 * Before any conversion, run ATT/bin/TTSServer -m 40 -c {mPort} -config
 * your-tts-conf.cfg
 */
public class ATTBin implements TTSService {
	private AudioFormat mAudioFormat;
	private String mATTPath;
	private int mSampleRate;
	private Pattern mMarkPattern;
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

	public ATTBin() throws SynthesisException {

		mLoadBalancer = new RoundRobinLoadBalancer(System.getProperty(
		        "att.servers", "localhost:8888"), null);
		mMarkPattern = Pattern.compile("([0-9]+)\\s+BOOKMARK:\\s+([^\\s]+)",
		        Pattern.MULTILINE);
		mSampleRate = 16000;
		mAudioFormat = new AudioFormat(mSampleRate, 16, 1, true, false);

		final String property = "att.client.path";
		mATTPath = BinaryFinder.find(property, "TTSClientFile");
		if (mATTPath == null) {
			throw new SynthesisException(
			        "Cannot find AT&T's client in PATH and " + property
			                + " is not set");
		}

		//test the synthesizer so that the service won't be active if it fails
		Host host = mLoadBalancer.selectHost();
		RawAudioBuffer testBuffer = new RawAudioBuffer();
		testBuffer.offsetInOutput = 0;
		testBuffer.output = new byte[1];
		synthesize("test", testBuffer, host, null,
		        new LinkedList<Map.Entry<String, Double>>(), 1);
		if (testBuffer.offsetInOutput <= 0) {
			throw new SynthesisException(
			        "AT&T client binary did not produce any audio data");
		}
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
	public Collection<Voice> getAvailableVoices() throws SynthesisException {
		Set<Voice> result = new HashSet<Voice>();
		//The client binary has no option to list all the voices, therefore we must
		//iterate over the possible voices and check if they are accepted.
		//If the server is smart enough, it can also return similar voices unknown 
		//from the TTS registry.
		//WARNING: all the AT&T servers are assumed to be configured with the same voices.
		Host host = mLoadBalancer.selectHost();
		String[] cmd = null;
		Pattern voicePattern = Pattern.compile("VOICE:\\s([^;]+)");
		Matcher mr = voicePattern.matcher("");

		File dest;
		try {
			dest = File.createTempFile("atttest", ".wav");
		} catch (IOException e1) {
			return null;
		}

		try {
			for (VoiceInfo voiceInfo : TTSRegistry.getAllPossibleVoices()) {
				if (voiceInfo.voice.vendor.equalsIgnoreCase("att")) {
					cmd = new String[]{
					        mATTPath, "-ssml", "-v0", "-s", host.address, "-p",
					        String.valueOf(host.port), "-o",
					        dest.getAbsolutePath()
					};

					Process p = Runtime.getRuntime().exec(cmd);
					p.getOutputStream()
					        .write(("<voice name=\"" + voiceInfo.voice.name + "\">t</voice>")
					                .getBytes());
					p.getOutputStream().close();
					InputStream is = p.getInputStream();
					Scanner scanner = new Scanner(is);
					while (scanner.hasNextLine()) {
						mr.reset(scanner.nextLine());
						if (mr.find()) {
							result.add(new Voice(getName(), mr.group(1)));
							break;
						}
					}
					is.close();
					p.waitFor();
				}
			}
		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		} finally {
			dest.delete();
		}

		return result;
	}
}
