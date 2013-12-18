package org.daisy.pipeline.audio.lame;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import javax.sound.sampled.AudioFormat;

import org.daisy.pipeline.audio.AudioEncoder;

public class LameEncoder implements AudioEncoder {
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
	public LameEncoder() throws Exception {
		final String property = "lame.path";
		mLamePath = findBinary(property, "lame");
		if (mLamePath == null) {
			throw new RuntimeException("Cannot find lame in PATH and " + property
			        + " is not set");
		}

		//check that the encoder can be run
		String[] cmd = new String[]{
		        mLamePath, "--help"
		};
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(cmd);
			//read the output to prevent the process from sleeping
			InputStream in = p.getInputStream();
			while (in.available() > 0) {
				in.skip(in.available());
			}
			p.waitFor();
		} catch (Exception e) {
			if (p != null)
				p.destroy();
			throw new Exception(e);
		}

	}

	@Override
	public String encode(byte[] input, int size, AudioFormat audioFormat, Object caller,
	        String name) {

		File encodedFile = null;
		if (name != null) {
			encodedFile = new File(System.getProperty("java.io.tmpdir") + "/" + name
			        + OutputFormat);
		} else {
			try {
				encodedFile = File.createTempFile("chunk", OutputFormat);
			} catch (IOException e) {
				return null;
			}
		}

		String freq = String.valueOf((Float.valueOf(audioFormat.getSampleRate()) / 1000));
		String bitwidth = String.valueOf(audioFormat.getSampleSizeInBits());
		String signedOpt = audioFormat.getEncoding() == AudioFormat.Encoding.PCM_SIGNED ? "--signed"
		        : "--unsigned";
		String endianness = audioFormat.isBigEndian() ? "--big-endian" : "--little-endian";

		//-r: raw pcm
		//-s: sample rate in kHz
		//-mm: mono
		//-: PCM read on the standard input
		String[] cmdbegin = new String[]{
		        mLamePath, "-r", "-s", freq, "--bitwidth", bitwidth, signedOpt, endianness,
		        "-m", "m", "--silent"
		};
		String[] custom = System.getProperty("lame.options", "").split(" ");
		String[] cmdend = new String[]{
		        "-", encodedFile.getAbsolutePath()
		};

		Process p = null;
		try {
			String[] cmd = new String[cmdbegin.length + custom.length + cmdend.length];
			System.arraycopy(cmdbegin, 0, cmd, 0, cmdbegin.length);
			System.arraycopy(custom, 0, cmd, cmdbegin.length, custom.length);
			System.arraycopy(cmdend, 0, cmd, cmdbegin.length + custom.length, cmdend.length);
			p = Runtime.getRuntime().exec(cmd);
			BufferedOutputStream out = new BufferedOutputStream((p.getOutputStream()));
			out.write(input, 0, size);
			out.close();
			p.waitFor();
		} catch (Exception e) {
			if (name == null)
				encodedFile.delete();
			if (p != null)
				p.destroy();
			return null;
		}

		return encodedFile.toURI().toString();
	}
}
