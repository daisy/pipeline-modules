package org.daisy.pipeline.tts.espeak;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashSet;
import java.util.List;
import java.util.Scanner;
import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.QName;

import org.daisy.pipeline.tts.BasicSSMLAdapter;
import org.daisy.pipeline.tts.BinaryFinder;
import org.daisy.pipeline.tts.MarkFreeTTSService;
import org.daisy.pipeline.tts.SSMLAdapter;

/**
 * This synthesizer uses directly the eSpeak binary. The voice names are used
 * for identifying the voices, but, for future improvements, their corresponding
 * file names could be used instead (with the -v option instead of <ssml:voice
 * name=...>), depending on how the connectors (SAPI etc.) manage the eSpeak
 * voices.
 */
public class ESpeakBinTTS extends MarkFreeTTSService {
	private AudioFormat mAudioFormat;
	private String[] mCmd;
	private SSMLAdapter mSSMLAdapter;
	private String mEspeakPath;
	private final static int MIN_CHUNK_SIZE = 2048;

	public void initialize() throws SynthesisException {
		final String property = "espeak.client.path";
		mEspeakPath = BinaryFinder.find(property, "espeak");

		if (mEspeakPath == null) {
			throw new SynthesisException("Cannot find eSpeak's binary and " + property
			        + " is not set");
		}

		mSSMLAdapter = new BasicSSMLAdapter() {
			@Override
			public String getHeader(String voiceName) {
				if (voiceName == null || voiceName.isEmpty()) {
					return "<voice>";
				}
				return "<voice name=\"" + voiceName + "\">";
			}

			@Override
			public String getFooter() {
				return "</voice>" + super.getFooter();
			}

			@Override
			public QName adaptElement(QName elementName) {
				if (elementName.getLocalName().equals("mark"))
					return null;
				return super.adaptElement(elementName);
			}
		};

		// '-m' tells eSpeak to interpret the input as SSML
		// '--stdout' tells eSpeak to print the result on the standard output
		// '--stdin' tells eSpeak to read the SSML from the standard input. It prevents it
		// from complaining about the size of the command line (when the sentences are big).
		mCmd = new String[]{
		        mEspeakPath, "-m", "--stdout", "--stdin"
		};;

		//Test the synthesizer so that the service won't be active if it fails.
		//It sets mAudioFormat too.
		mAudioFormat = null;
		Object r = allocateThreadResources();
		synthesize(mSSMLAdapter.getHeader(null) + "x" + mSSMLAdapter.getFooter(), null, r,
		        new ArrayList<RawAudioBuffer>());
		releaseThreadResources(r);
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
	public String getVersion() {
		return "command-line";
	}

	@Override
	public void afterReleasingResources() throws SynthesisException {
		mAudioFormat = null;
		mCmd = null;
		mSSMLAdapter = null;
		mEspeakPath = null;
	}

	@Override
	public int getOverallPriority() {
		return Integer.valueOf(System.getProperty("espeak.bin.priority", "1"));
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException {
		Collection<Voice> result;
		InputStream is;
		Process proc = null;
		Scanner scanner;
		Matcher mr;
		try {
			//First: get the list of all the available languages
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
			proc = null;

			//Second: get the list of the voices for the found languages.
			//White spaces are not allowed in voice names
			result = new ArrayList<Voice>();
			mr = Pattern.compile("^\\s*[0-9]+\\s+[-a-z]+\\s+([FM]\\s+)?([^ ]+)").matcher("");
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
			if (proc != null) {
				proc.destroy();
			}
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		return result;
	}

	@Override
	public SSMLAdapter getSSMLAdapter() {
		return mSSMLAdapter;
	}

	@Override
	public void synthesize(String ssml, Voice voice, Object threadResources,
	        List<RawAudioBuffer> output) throws SynthesisException {
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(mCmd);

			//write the SSML
			BufferedOutputStream out = new BufferedOutputStream((p.getOutputStream()));
			out.write(ssml.getBytes("utf-8"));
			out.close();

			//read the wave on the standard output
			BufferedInputStream in = new BufferedInputStream(p.getInputStream());
			AudioInputStream fi = AudioSystem.getAudioInputStream(in);

			if (mAudioFormat == null)
				mAudioFormat = fi.getFormat();

			while (true) {
				RawAudioBuffer b = new RawAudioBuffer();
				int toread = MIN_CHUNK_SIZE + fi.available();
				b.output = new byte[toread];
				b.offsetInOutput = fi.read(b.output, 0, toread);
				if (b.offsetInOutput == -1)
					break;
				output.add(b);
			}

			fi.close();
			p.waitFor();
		} catch (Exception e) {
			if (p != null)
				p.destroy();
		}
	}
}
