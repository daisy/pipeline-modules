package org.daisy.pipeline.tts.google.impl;

import java.util.Map;

import org.daisy.pipeline.tts.AbstractTTSService;
import org.daisy.pipeline.tts.TTSEngine;
import org.daisy.pipeline.tts.TTSService;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;

@Component(
		name = "google-tts-service",
		service = { TTSService.class }
		)
public class GoogleTTSService extends AbstractTTSService {

	@Activate
	protected void loadSSMLadapter() {
		super.loadSSMLadapter("/transform-ssml.xsl", GoogleTTSService.class);
	}

	@Override
	public TTSEngine newEngine(Map<String, String> params) throws Throwable {
		
		int priority = 2;
		
		// String apiKey = params.get("org.daisy.pipeline.tts.google.apikey");
		
		String apiKey = "AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM";

		return new GoogleRestTTSEngine(this, apiKey, priority);

	}

	@Override
	public String getName() {
		return "google";
	}

	@Override
	public String getVersion() {
		return "cli";
	}
}
