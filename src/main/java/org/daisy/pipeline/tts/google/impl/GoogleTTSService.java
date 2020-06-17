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

		// temporary
		int intPriority = 2;
		// to pass later in the options
		String jsonPath = "/Users/louiscaille/Documents/Pipeline/pipeline-b15bde01d04a.json"; 
		
		return new GoogleTTSEngine(this, jsonPath, intPriority);
		
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
