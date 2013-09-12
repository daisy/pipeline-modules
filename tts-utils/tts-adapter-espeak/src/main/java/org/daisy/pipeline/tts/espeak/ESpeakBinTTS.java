package org.daisy.pipeline.tts.espeak;

import java.io.File;
import java.io.IOException;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.TTSService;

/**
 * This synthesizer uses directly the espeak binary and intermediate WAV files.
 */
public class ESpeakBinTTS implements TTSService {

	private AudioFormat mAudioFormat;
	private String mEspeakPath;

	private static String findExecutableOnPath(String executableName) {
		String systemPath = System.getenv("PATH");
		String[] pathDirs = systemPath.split(File.pathSeparator);

		File fullyQualifiedExecutable = null;
		for (String pathDir : pathDirs) {
			File file = new File(pathDir, executableName);
			if (file.isFile()) {
				fullyQualifiedExecutable = file;
				break;
			}
		}
		return fullyQualifiedExecutable.getAbsolutePath();
	}

	//TODO: take the path from the properties if it exists
	//and raise an exception if nothing is found
	public ESpeakBinTTS() {
		mAudioFormat = new AudioFormat(22050, 16, 1, true, false);
		mEspeakPath = findExecutableOnPath("espeak");
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object caller, Object lastCallMemory) throws SynthesisException {

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

			ssml.toString();

			String[] cmd = null;
			try {
				// '-m' tells to interpret the input as SSML
				// '-w' tells to dump the result to a WAV file
				cmd = new String[]{
				        mEspeakPath, "-m", "-w", dest.getAbsolutePath(),
				        "\"" + ssml.toString() + "\""
				};
				Runtime.getRuntime().exec(cmd).waitFor();
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
}
