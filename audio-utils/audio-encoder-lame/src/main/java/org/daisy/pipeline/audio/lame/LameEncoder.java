package org.daisy.pipeline.audio.lame;

import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.File;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Arrays;

import javax.sound.sampled.AudioFormat;

import org.daisy.common.shell.BinaryFinder;
import org.daisy.pipeline.audio.AudioEncoder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.base.Joiner;
import com.google.common.base.Optional;

public class LameEncoder implements AudioEncoder {

	private Logger mLogger = LoggerFactory.getLogger(LameEncoder.class);

	private static final String OutputFormat = ".mp3";
	private String mLamePath;

	public LameEncoder() throws Exception {
		final String property = "lame.path";
		mLamePath = System.getProperty(property);
		if (mLamePath == null) {
			Optional<String> lpath = BinaryFinder.find("lame");
			if (!lpath.isPresent()) {
				throw new RuntimeException("Cannot find lame in PATH and " + property
				        + " is not set");
			}
			mLamePath = lpath.get();
		}
		mLogger.info("Will use lame binary: " + mLamePath);

		//check that the encoder can run
		String[] cmd = new String[]{
		        mLamePath, "--help"
		};
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(cmd);
			//read the output to prevent the process from sleeping
			BufferedReader stdOut=new BufferedReader(new InputStreamReader(p.getInputStream()));
			while((stdOut.readLine())!=null){}
			p.waitFor();
		} catch (Exception e) {
			if (p != null)
				p.destroy();
			throw new Exception(e);
		}
	}

	@Override
	public String encode(byte[] input, int size, AudioFormat audioFormat, Object caller,
	        File outputDir, String filePrefix) {

		File encodedFile = new File(outputDir, filePrefix + OutputFormat);
		String freq = String.valueOf((Float.valueOf(audioFormat.getSampleRate()) / 1000));
		String bitwidth = String.valueOf(audioFormat.getSampleSizeInBits());
		String signedOpt = audioFormat.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED ? "--unsigned"
		        : "--signed";
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
			mLogger.debug("Encoding command: {}", Joiner.on(' ').join(Arrays.asList(cmd)));
			p = Runtime.getRuntime().exec(cmd);
			BufferedOutputStream out = new BufferedOutputStream((p.getOutputStream()));
			out.write(input, 0, size);
			out.close();
			p.waitFor();
		} catch (Exception e) {
			if (p != null)
				p.destroy();
			return null;
		}

		return encodedFile.toURI().toString();
	}
}
