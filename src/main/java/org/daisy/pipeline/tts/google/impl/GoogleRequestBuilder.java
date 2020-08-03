package org.daisy.pipeline.tts.google.impl;

import java.net.URL;

public class GoogleRequestBuilder {
	
	public enum Action {
		VOICES("GET","/v1/voices"),
		SPEECH("POST","/v1/text:synthesize");
		
		public String method;
		public String domain;

		Action(String method, String domain) {
			this.method = method;
			this.domain = domain;
		}
	}
	
	private String apiKey;
	private int sampleRate;
	private Action action;
	private String requestParameters;
	private String text;
	private String languageCode;
	private String voice;
	
	public GoogleRequestBuilder(String apiKey) {
		this.apiKey = apiKey;
	}
	
	public GoogleRequestBuilder withAction(Action action) {
		this.action = action;
		return this;
	}
	
	public GoogleRequestBuilder withLanguageCode(String languageCode) {
		this.languageCode = languageCode;
		return this;
	}
	
	public GoogleRequestBuilder withVoice(String voice) {
		this.voice = voice;
		return this;
	}

	public GoogleRequestBuilder withText(String text) {
		this.text = text;
		return this;
	}
	
	public GoogleRequestBuilder newRequest() {
		return new GoogleRequestBuilder(apiKey);
	}
	
	public GoogleRestRequest build() throws Exception {
		
		GoogleRestRequest restRequest = new GoogleRestRequest();
		
		String requestUrl = "https://texttospeech.googleapis.com" + action.domain + "?key=" + apiKey;
		restRequest.setRequestUrl(new URL(requestUrl));
		
		switch(action) {
		case VOICES:
			restRequest.setDoOutput(false);
			break;
		case SPEECH:
			requestParameters = "{";
			requestParameters += "\"input\":{\"ssml\":" + '"' + text + '"' + "},";
			requestParameters += "\"voice\":{\"languageCode\":" + '"' + languageCode +'"' + ",";
			requestParameters += "\"name\":" + '"' + voice + '"' + "},";
			requestParameters += "\"audioConfig\":{\"audioEncoding\":\"LINEAR16\",";
			requestParameters += "\"sampleRateHertz\":" + '"' + sampleRate + '"' + "}";
			requestParameters += "}";
			restRequest.setRequestParameters(requestParameters);
			restRequest.setDoOutput(true);
			break;
		}
		
		return restRequest;
	}

}
