package org.daisy.pipeline.audio.lame.impl;

import java.io.BufferedReader;
import java.io.File;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Optional;

import javax.sound.sampled.AudioFileFormat;

import org.daisy.common.shell.BinaryFinder;
import org.daisy.pipeline.audio.AudioEncoder;
import org.daisy.pipeline.audio.AudioEncoderService;
import static org.daisy.pipeline.audio.AudioFileTypes.MP3;

import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "audio-encoder-lame",
	immediate = true,
	service = { AudioEncoderService.class }
)
public class LameEncoderService implements AudioEncoderService {

	private static final Logger logger = LoggerFactory.getLogger(LameEncoderService.class);

	@Override
	public boolean supportsFileType(AudioFileFormat.Type fileType) {
		 return MP3.equals(fileType);
	}

	@Override
	public Optional<AudioEncoder> newEncoder(Map<String,String> params) {
		LameEncoder.LameEncodingOptions lameOpts = parseEncodingOptions(params);
		try {
			test(lameOpts);
			return Optional.of(new LameEncoder(lameOpts));
		} catch (Exception e) {
			logger.error("Lame encoder can not be instantiated", e);
			return Optional.empty();
		}
	}

	private static LameEncoder.LameEncodingOptions parseEncodingOptions(Map<String,String> params) {
		LameEncoder.LameEncodingOptions opts = new LameEncoder.LameEncodingOptions();
		{
			String prop = "org.daisy.pipeline.tts.mp3.bitrate";
			String bitrate = params.get(prop);
			if (bitrate != null) {
				try {
					opts.bitrate = Integer.valueOf(bitrate);
				} catch (NumberFormatException e) {
					logger.warn(prop + ": " + bitrate + "is not a valid number");
				}
			}
		}
		{
			String prop = "org.daisy.pipeline.tts.lame.cli.options";
			String extraCliArguments = params.get(prop);
			if (extraCliArguments != null) {
				logger.warn("'" + prop + "' setting is deprecated. It may become unavailable in future version of DAISY Pipeline.");
				opts.extraCliArguments = extraCliArguments.split(" ");
			}
		}
		{
			String prop = "org.daisy.pipeline.tts.lame.path";
			opts.binpath = params.get(prop);
			if (opts.binpath == null) {
				Optional<String> lpath = BinaryFinder.find("lame");
				if (lpath.isPresent())
					opts.binpath = lpath.get();
			}
		}
		return opts;
	}

	private static void test(LameEncoder.LameEncodingOptions lameOpts) throws Exception {
		if (lameOpts.binpath == null) {
			throw new RuntimeException("Lame executable not found");
		}
		if (!new File(lameOpts.binpath).exists()) {
			throw new RuntimeException("Lame executable not found: " + lameOpts.binpath);
		}
		// check that the encoder can run
		String[] cmd = new String[] {
			lameOpts.binpath, "--help"
		};
		Process p = null;
		try {
			p = Runtime.getRuntime().exec(cmd);
			// read the output to prevent the process from sleeping
			BufferedReader stdOut = new BufferedReader(new InputStreamReader(p.getInputStream()));
			while ((stdOut.readLine()) != null);
			p.waitFor();
		} catch (Exception e) {
			if (p != null)
				p.destroy();
			throw e;
		}
	}
}
