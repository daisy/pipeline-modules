package org.daisy.pipeline.tts.google.impl;

import java.net.URL;

/**
 * Google REST Request builder class.
 * 
 * @author Louis Caille @ braillenet.org
 *
 */
public class GoogleRequestBuilder {
	
	/**
	 * Google API key
	 */
	private String apiKey;
	
	/**
	 * Encoding sample rate (if null, uses the default encoding)
	 */
	private Integer sampleRate = null;
	
	private GoogleRestAction action;
	
	private String requestParameters = null;
	private String text = null;
	private String languageCode = null;
	private String voice = null;
	
	/**
	 * 
	 * @param apiKey the API key to access google services (to create from your google cloud console API identifiers)
	 */
	public GoogleRequestBuilder(String apiKey) {
		this.apiKey = apiKey;
	}
	
	/**
	 * Set the action to execute
	 * @param action 
	 * @return
	 */
	public GoogleRequestBuilder withAction(GoogleRestAction action) {
		this.action = action;
		return this;
	}
	
	/**
	 * Mandatory - set the language code of the next requests
	 * @param languageCode language code of the voice
	 * @return
	 */
	public GoogleRequestBuilder withLanguageCode(String languageCode) {
		this.languageCode = languageCode;
		return this;
	}
	
	/**
	 * Set the voice name to use for the next requests
	 * @param voice
	 * @return
	 */
	public GoogleRequestBuilder withVoice(String voice) {
		this.voice = voice;
		return this;
	}

	/**
	 * Mandatory - Set the text to synthesise for the next requests
	 * @param text
	 * @return
	 */
	public GoogleRequestBuilder withText(String text) {
		this.text = text;
		return this;
	}
	
	/**
	 * Set the sample rate of the next requests
	 * @param sampleRateHertz
	 * @return
	 */
	public GoogleRequestBuilder withSampleRate(int sampleRateHertz) {
		this.sampleRate = Integer.valueOf(sampleRateHertz);
		return this;
	}
	
	/**
	 * Create a new builder instance with all value except the api key set to defaults.
	 * @return a new builder to use for building a request
	 */
	public GoogleRequestBuilder newRequest() {
		return new GoogleRequestBuilder(apiKey);
	}
	
	/**
	 * Build a rest request to send for google could text to speech
	 * @return
	 * @throws Exception
	 */
	public GoogleRestRequest build() throws Exception {
		
		GoogleRestRequest restRequest = new GoogleRestRequest();
		
		String requestUrl = "https://texttospeech.googleapis.com" + action.domain + "?key=" + apiKey;
		restRequest.setRequestUrl(new URL(requestUrl));
		
		switch(action) {
		case VOICES:
			// No specific parameters
			break;
		case SPEECH:
			// speech synthesis errors handling
			if(this.text == null || text.length() == 0) 
				throw new Exception("Speech request without text.");
			if(languageCode == null || languageCode.length() == 0) 
				throw new Exception("Language code definition is mandatory, please set one (speech request for " + text + ")");
			
			requestParameters = "{";
			requestParameters += "\"input\":{\"ssml\":" + '"' + text + '"' + "},";
			requestParameters += "\"voice\":{"
					+ "\"languageCode\":" + '"' + languageCode +'"';
			if(voice != null && voice.length() > 0) {
				requestParameters += ",\"name\":" + '"' + voice + '"';
			}
			requestParameters += "},\"audioConfig\":{"
					+ "\"audioEncoding\":\"LINEAR16\"";
			if(this.sampleRate != null) {
				requestParameters += ",\"sampleRateHertz\":" + '"' + sampleRate + '"';
			}
			requestParameters += "}}";
			restRequest.setRequestParameters(requestParameters);
			break;
		}
		restRequest.setMethod(action.method);
		
		return restRequest;
	}

}
