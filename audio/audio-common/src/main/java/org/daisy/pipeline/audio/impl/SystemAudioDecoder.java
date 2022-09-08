package org.daisy.pipeline.audio.impl;

import java.io.File;
import java.util.Map;
import java.util.Optional;

import javax.sound.sampled.AudioFileFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.UnsupportedAudioFileException;

import org.daisy.pipeline.audio.AudioDecoder;
import org.daisy.pipeline.audio.AudioDecoderService;
import org.daisy.pipeline.audio.AudioFileTypes;

import org.osgi.service.component.annotations.Component;

@Component(
	name = "system-audio-decoder",
	immediate = true,
	service = { AudioDecoderService.class }
)
public class SystemAudioDecoder implements AudioDecoderService {

	@Override
	public boolean supportsFileType(AudioFileFormat.Type fileType) {
		return AudioFileTypes.WAVE.equals(fileType);
	}

	@Override
	public Optional<AudioDecoder> newDecoder(Map<String,String> params) {
		return Optional.of(getInstance());
	}

	static AudioDecoder instance = null;

	static AudioDecoder getInstance() {
		if (instance == null)
			instance = new AudioDecoder() {
					@Override
					public AudioInputStream decode(File inputFile) throws UnsupportedAudioFileException, Throwable {
						return AudioSystem.getAudioInputStream(inputFile);
					}
				};
		return instance;
	}
}
