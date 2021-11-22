package org.daisy.pipeline.audio;

import java.util.Collection;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.Map;
import java.util.Optional;

import javax.sound.sampled.AudioFileFormat;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "audio-services",
	service = { AudioServices.class }
)
public class AudioServices {

	public Optional<AudioEncoder> newEncoder(AudioFileFormat.Type fileType, Map<String,String> params) {
		for (AudioEncoderService s : encoderServices) {
			if (s.supportsFileType(fileType)) {
				Optional<AudioEncoder> e = s.newEncoder(params);
				if (e.isPresent())
					return e;
			}
		}
		return Optional.empty();
	}

	public Optional<AudioDecoder> newDecoder(AudioFileFormat.Type fileType, Map<String,String> params) {
		for (AudioDecoderService s : decoderServices) {
			if (s.supportsFileType(fileType)) {
				Optional<AudioDecoder> d = s.newDecoder(params);
				if (d.isPresent())
					return d;
			}
		}
		return Optional.empty();
	}

	private final Collection<AudioEncoderService> encoderServices = new CopyOnWriteArrayList<>();
	private final Collection<AudioDecoderService> decoderServices = new CopyOnWriteArrayList<>();

	@Reference(
		name = "audio-encoder-service",
		unbind = "removeEncoderService",
		service = AudioEncoderService.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	public void addEncoderService(AudioEncoderService service) {
		encoderServices.add(service);
	}

	public void removeEncoderService(AudioEncoderService service) {
		encoderServices.remove(service);
	}

	@Reference(
		name = "audio-decoder-service",
		unbind = "removeDecoderService",
		service = AudioDecoderService.class,
		cardinality = ReferenceCardinality.MULTIPLE,
		policy = ReferencePolicy.DYNAMIC
	)
	public void addDecoderService(AudioDecoderService service) {
		decoderServices.add(service);
	}

	public void removeDecoderService(AudioDecoderService service) {
		decoderServices.remove(service);
	}
}
