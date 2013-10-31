package org.daisy.pipeline.tts.espeak;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Map.Entry;
import java.util.Scanner;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

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
 * The voice names are used to identify the voices, but their corresponding file
 * names could be used instead (with the -v option instead of <ssml:voice
 * name=...>), depending on how the connectors, such as SAPI, manage eSpeak.
 */
public class ESpeakBinTTS implements TTSService {
	private AudioFormat mAudioFormat;
	private String mEspeakPath;
	private SSMLAdapter mSSMLAdapter = new BasicSSMLAdapter() {
		@Override
		public String getHeader(String voiceName) {
			if (voiceName == null || voiceName.isEmpty()) {
				return "<voice>";
			}
			return "<voice name=\"" + voiceName + "\"/>";
		}

		@Override
		public String getFooter() {
			return "</voice>";
		}

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

	public void initialize() throws SynthesisException {
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
	public Collection<Voice> getAvailableVoices() throws SynthesisException {
		Collection<Voice> result;
		//retrieve the list of installed voices
		InputStream is;
		Process proc;
		Scanner scanner;
		Matcher mr;
		try {
			//first: get the list of all the available languages
			Set<String> languages = new HashSet<String>();
			proc = Runtime.getRuntime().exec(new String[]{
			        mEspeakPath, "--voices"
			});
			is = proc.getInputStream();
			mr = Pattern.compile("\\s*[0-9]+\\s+([-a-z]+)").matcher("");
			scanner = new Scanner(is);
			scanner.nextLine(); //headers
			while (scanner.hasNextLine()) {
				mr.reset(scanner.nextLine());
				mr.find();
				languages.add(mr.group(1).split("-")[0]);
			}
			is.close();
			proc.waitFor();

			//second:get the list of the voices for the found languages.
			//Whitespaces are not allowed in voice names
			result = new ArrayList<Voice>();
			mr = Pattern
			        .compile("^\\s*[0-9]+\\s+[-a-z]+\\s+([FM]\\s+)?([^ ]+)")
			        .matcher("");
			for (String lang : languages) {
				proc = Runtime.getRuntime().exec(new String[]{
				        mEspeakPath, "--voices=" + lang
				});
				is = proc.getInputStream();
				scanner = new Scanner(is);
				scanner.nextLine(); //headers
				while (scanner.hasNextLine()) {
					mr.reset(scanner.nextLine());
					mr.find();
					result.add(new Voice(getName(), mr.group(2).trim()));
				}
				is.close();
				proc.waitFor();
			}

		} catch (Exception e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		return result;
	}
}
