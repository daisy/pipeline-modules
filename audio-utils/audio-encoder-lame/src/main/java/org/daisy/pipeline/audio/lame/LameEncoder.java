package org.daisy.pipeline.audio.lame;

import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import org.daisy.pipeline.audio.AudioEncoder;

public class LameEncoder implements AudioEncoder {
	private static final String InputFormat = ".wav";
	private static final String OutputFormat = ".mp3";

	private static final String[] winExtensions = {
	        ".exe", ".bat", ".cmd", ".bin", ""
	};
	private static final String[] nixExtensions = {
	        "", ".run", ".bin", ".sh"
	};
	private String mLamePath;

	private String findBinary(String propertyName, String executableName) {
		String result = System.getProperty(propertyName);
		if (result != null)
			return result;

		String os = System.getProperty("os.name");
		String[] extensions;
		if (os != null && os.startsWith("Windows"))
			extensions = winExtensions;
		else
			extensions = nixExtensions;

		String systemPath = System.getenv("PATH");
		String[] pathDirs = systemPath.split(File.pathSeparator);
		for (String ext : extensions) {
			String fullname = executableName + ext;
			for (String pathDir : pathDirs) {
				File file = new File(pathDir, fullname);
				if (file.isFile()) {
					return file.getAbsolutePath();
				}
			}
		}
		return null;
	}

	//TODO: call the TTS's BinaryFinder.find instead of findBinary
	public LameEncoder() throws InterruptedException, IOException {
		final String property = "lame.path";
		mLamePath = findBinary(property, "lame");
		if (mLamePath == null) {
			throw new RuntimeException("Cannot find lame in PATH and "
			        + property + " is not set");
		}

		//check that the encoder can be run
		String[] cmd = new String[]{
		        mLamePath, "--help"
		};
		Runtime.getRuntime().exec(cmd).waitFor();
	}

	@Override
	public String encode(byte[] input, int size, AudioFormat audioFormat,
	        Object caller, String name) {
		// generate the intermediate WAV file from the input audio data
		File intermediateFile;
		try {
			intermediateFile = File.createTempFile("chunk", InputFormat);
		} catch (IOException e1) {
			return null;
		}
		try {
			InputStream inputStream = new ByteArrayInputStream(input);
			AudioInputStream ais = new AudioInputStream(inputStream,
			        audioFormat, size / audioFormat.getFrameSize());

			AudioSystem.write(ais, AudioFileFormat.Type.WAVE, intermediateFile);
			ais.close();
			inputStream.close();
		} catch (FileNotFoundException e1) {
			intermediateFile.delete();
			return null;
		} catch (IOException e) {
			intermediateFile.delete();
			return null;
		}

		// execute the lame binary on the intermediate WAV file
		File encodedFile = null;
		String[] cmd = null;
		try {
			if (name != null) {
				encodedFile = new File(System.getProperty("java.io.tmpdir")
				        + "/" + name + OutputFormat);
			} else {
				encodedFile = File.createTempFile("chunk", OutputFormat);
			}

			cmd = new String[]{
			        mLamePath, "--silent", intermediateFile.getAbsolutePath(),
			        encodedFile.getAbsolutePath()
			};
			Runtime.getRuntime().exec(cmd).waitFor();

		} catch (Exception e) {
			encodedFile = null;
			return null;
		} finally {
			intermediateFile.delete();
		}

		return encodedFile.toURI().toString();
	}
}
