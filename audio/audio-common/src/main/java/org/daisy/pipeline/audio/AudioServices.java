package org.daisy.pipeline.audio;

import java.util.Collection;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.Map;
import java.util.Optional;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.component.annotations.ReferenceCardinality;
import org.osgi.service.component.annotations.ReferencePolicy;

@Component(
	name = "audio-services",
	service = { AudioServices.class }
)
public class AudioServices implements AudioEncoderService {

	public Optional<AudioEncoder> newEncoder(Map<String,String> params) {
		for (AudioEncoderService s : encoderServices) {
			Optional<AudioEncoder> e = s.newEncoder(params);
			if (e.isPresent())
				return e;
		}
		return Optional.empty();
	}

	private final Collection<AudioEncoderService> encoderServices = new CopyOnWriteArrayList<>();

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
}
