package org.daisy.pipeline.audio.lame.impl;

import java.io.BufferedOutputStream;
import java.io.File;
import java.io.OutputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Optional;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;

import org.daisy.common.shell.CommandRunner;
import org.daisy.common.shell.CommandRunner.Consumer;
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
	public Optional<String> encode(AudioInputStream pcm, File outputDir, String filePrefix)
			throws Throwable {

		AudioFormat audioFormat = pcm.getFormat();
		File encodedFile = new File(outputDir, filePrefix + OutputFormat);
		String freq = String.valueOf((Float.valueOf(audioFormat.getSampleRate()) / 1000));
		String bitwidth = String.valueOf(audioFormat.getSampleSizeInBits());
		String signedOpt = audioFormat.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED ? "--unsigned"
		        : "--signed";
		String endianness = audioFormat.isBigEndian() ? "--big-endian" : "--little-endian";
		Consumer<OutputStream> lameInput;

		// Lame cannot deal with unsigned encoding for other bitwidths than 8
		if (audioFormat.getEncoding() == AudioFormat.Encoding.PCM_UNSIGNED
		        && audioFormat.getSampleSizeInBits() > 8
		        && (audioFormat.getSampleSizeInBits() % 8) == 0) {
			// downsampling: keep the most significant bit only, in order to produce 8-bit unsigned data
			int ratio = audioFormat.getSampleSizeInBits() / 8;
			int mse = audioFormat.isBigEndian() ? 0 : (ratio - 1);
			bitwidth = "8";
			lameInput = stream -> {
				try (BufferedOutputStream out = new BufferedOutputStream(stream)) {
					byte[] frame = new byte[audioFormat.getFrameSize()];
					while (pcm.read(frame) > 0)
						for (int i = 0; i < frame.length; i += ratio)
							out.write(frame[i + mse]);
				}
			};
		} else if (audioFormat.getEncoding() == AudioFormat.Encoding.PCM_FLOAT) {
			// convert [-1.0, 1.0] values to regular 32-bit signed integers
			// FIXME: find a faster and more accurate way
			if (audioFormat.getSampleSizeInBits() == 32) {
				lameInput = stream -> {
					try (BufferedOutputStream out = new BufferedOutputStream(stream)) {
						ByteBuffer frame = ByteBuffer.wrap(new byte[audioFormat.getFrameSize()]);
						ByteOrder byteOrder = audioFormat.isBigEndian() ? ByteOrder.BIG_ENDIAN : ByteOrder.LITTLE_ENDIAN;
						while (pcm.read(frame.array()) > 0) {
							frame.order(byteOrder);
							// read floats and write ints (both 4 bytes)
							for (int i = 0; i < frame.array().length; i += 4)
								frame.putInt(0, (int)(frame.getFloat(i) * Integer.MAX_VALUE));
							out.write(frame.array(), 0, 4);
						}
					}
				};
			} else { // Lame cannot handle 64-bit data => downsampling to 32-bit
				bitwidth = "32";
				lameInput = stream -> {
					try (BufferedOutputStream out = new BufferedOutputStream(stream)) {
						ByteBuffer frame = ByteBuffer.wrap(new byte[audioFormat.getFrameSize()]);
						ByteOrder byteOrder = audioFormat.isBigEndian() ? ByteOrder.BIG_ENDIAN : ByteOrder.LITTLE_ENDIAN;
						while (pcm.read(frame.array()) > 0) {
							frame.order(byteOrder);
							// read doubles (8 bytes) and write ints (4 bytes)
							for (int i = 0; i < frame.array().length; i += 8)
								frame.putInt(0, (int)(frame.getDouble(i) * Integer.MAX_VALUE));
							out.write(frame.array(), 0, 4);
						}
					}
				};
			}
		} else {
			lameInput = stream -> {
				try (BufferedOutputStream out = new BufferedOutputStream(stream)) {
					byte[] frame = new byte[audioFormat.getFrameSize()];
					while (pcm.read(frame) > 0)
						out.write(frame);
				}
			};
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
			.feedInput(lameInput)
			.consumeError(mLogger)
			.run();

		return Optional.of(encodedFile.toURI().toString());
	}
}
