package org.daisy.pipeline.audio.lame.impl;

import java.io.BufferedOutputStream;
import java.io.File;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Optional;

import javax.sound.sampled.AudioFormat;

import org.daisy.common.shell.CommandRunner;
import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.audio.AudioEncoder;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class LameEncoder implements AudioEncoder {

	static class LameEncodingOptions {
		String binpath;
		String[] cliOptions;
	}

	private static final Logger mLogger = LoggerFactory.getLogger(LameEncoder.class);
	private static final String OutputFormat = ".mp3";

	private final LameEncodingOptions lameOpts;

	LameEncoder(LameEncodingOptions lameOpts) {
		this.lameOpts = lameOpts;
	}

	@Override
	public Optional<String> encode(Iterable<AudioBuffer> pcm, AudioFormat audioFormat,
	                               File outputDir, String filePrefix) throws Throwable {

		File encodedFile = new File(outputDir, filePrefix + OutputFormat);
		String freq = String.valueOf((Float.valueOf(audioFormat.getSampleRate()) / 1000));
		String bitwidth = String.valueOf(audioFormat.getSampleSizeInBits());
		String signedOpt = audioFormat.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED ? "--unsigned"
		        : "--signed";
		String endianness = audioFormat.isBigEndian() ? "--big-endian" : "--little-endian";

		//lame cannot deal with unsigned encoding for other bitwidths than 8
		if (audioFormat.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED
		        && audioFormat.getSampleSizeInBits() > 8
		        && (audioFormat.getSampleSizeInBits() % 8) == 0) {
			//downsampling: keep the most significant bit only, in order to produce 8-bit unsigned data
			int ratio = audioFormat.getSampleSizeInBits() / 8;
			int mse = audioFormat.isBigEndian() ? 0 : (ratio - 1);
			for (AudioBuffer buffer : pcm) {
				buffer.size /= ratio;
				for (int i = 0; i < buffer.size; ++i)
					buffer.data[i] = buffer.data[ratio * i + mse];
			}
			bitwidth = "8";
		} else if (audioFormat.getEncoding() == AudioFormat.Encoding.PCM_FLOAT) {
			//convert [-1.0, 1.0] values to regular 32-bit signed integers
			//TODO: find a faster and more accurate way

			if (audioFormat.getSampleSizeInBits() == 32) {
				for (AudioBuffer b : pcm) {
					ByteBuffer buffer = ByteBuffer.wrap(b.data, 0, b.size);
					buffer.order(audioFormat.isBigEndian() ? ByteOrder.BIG_ENDIAN
					        : ByteOrder.LITTLE_ENDIAN);
					for (int i = 0; i < b.size; i += Float.SIZE / 8) {
						float v = buffer.getFloat(i);
						buffer.putInt(i, (int) (v * Integer.MAX_VALUE));
					}
				}
			} else { //Lame cannot handle 64-bit data => downsampling to 32-bit
				for (AudioBuffer b : pcm) {
					ByteBuffer buffer = ByteBuffer.wrap(b.data, 0, b.size);
					buffer.order(audioFormat.isBigEndian() ? ByteOrder.BIG_ENDIAN
					        : ByteOrder.LITTLE_ENDIAN);
					for (int i = 0; i < b.size; i += Double.SIZE / 8) {
						double v = buffer.getDouble(i);
						buffer.putInt(i / 2, (int) (v * Integer.MAX_VALUE));
					}
					b.size /= 2;
				}
				bitwidth = "32";
			}
		}

		//-r: raw pcm
		//-s: sample rate in kHz
		//-mm: mono
		//-: PCM read on the standard input
		String[] cmdbegin = new String[]{
		        lameOpts.binpath, "-r", "-s", freq, "--bitwidth", bitwidth, signedOpt,
		        endianness, "-m", "m", "--silent"
		};
		String[] cmdend = new String[]{
		        "-", encodedFile.getAbsolutePath()
		};

		String[] cmd = new String[cmdbegin.length + lameOpts.cliOptions.length
		        + cmdend.length];
		System.arraycopy(cmdbegin, 0, cmd, 0, cmdbegin.length);
		System.arraycopy(lameOpts.cliOptions, 0, cmd, cmdbegin.length,
		        lameOpts.cliOptions.length);
		System.arraycopy(cmdend, 0, cmd, cmdbegin.length + lameOpts.cliOptions.length,
		        cmdend.length);
		new CommandRunner(cmd)
			.feedInput(stream -> {
					try (BufferedOutputStream out = new BufferedOutputStream(stream)) {
						for (AudioBuffer b : pcm) {
							out.write(b.data, 0, b.size);
						}
					}
				}
			)
			.consumeError(mLogger)
			.run();

		return Optional.of(encodedFile.toURI().toString());
	}
}
