package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.MarklessTTSEngine;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;
import org.daisy.pipeline.tts.google.impl.GoogleRequestBuilder.Action;

/**
 * Connector class to synthesize audio using the google cloud tts engine.
 * This connector is based on their REST Api.
 * 
 * @author Louis Caille @ braillenet.org
 *
 */
public class GoogleRestTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private RequestScheduler<GoogleRestRequest> mRequestScheduler;
	private int mPriority;
	private GoogleRequestBuilder mRequestBuilder;
	
	public GoogleRestTTSEngine(GoogleTTSService googleService, String apiKey, AudioFormat audioFormat, 
			RequestScheduler<GoogleRestRequest> requestScheduler, int priority) {
		super(googleService);
		mPriority = priority;
		mAudioFormat = audioFormat;
		mRequestScheduler = requestScheduler;
		mRequestBuilder = new GoogleRequestBuilder(apiKey);
		
	}

	@Override
	public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
			Voice voice, TTSResource threadResources, AudioBufferAllocator bufferAllocator, boolean retry)
					throws SynthesisException,InterruptedException, MemoryException {
		
		if (sentence.length() > 5000) {
			throw new SynthesisException("The number of characters in the sentence must not exceed 5000.");
		}

		Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();

		// the sentence must be in an appropriate format to be inserted in the json query
		// it is necessary to wrap the sentence in quotes and add backslash in front of the existing quotes
		
		String adaptedSentence = "";
		
		for (int i = 0; i < sentence.length(); i++) {
			if (sentence.charAt(i) == '"') {
				adaptedSentence = adaptedSentence + '\\' + sentence.charAt(i);
			}
			else {
				adaptedSentence = adaptedSentence + sentence.charAt(i);
			}
		}
		
		String languageCode;
		String name;
		int indexOfSecondHyphen;

		if (voice != null) {
			//recovery of the language code in the name of the voice
			indexOfSecondHyphen = voice.name.indexOf('-', voice.name.indexOf('-') + 1);
			languageCode = voice.name.substring(0, indexOfSecondHyphen);
			name = voice.name;
		}
		else {
			// by default the voice is set to English
			languageCode = "en-GB";
			name = "en-GB-Standard-A";
		}
		
		GoogleRestRequest speechRequest = null;
		GoogleRestRequest request = null;
		UUID requestUuid = null;
		boolean isNotDone = true;
		
		try {
			
			speechRequest = mRequestBuilder.newRequest()
					.withAction(Action.SPEECH)
					.withLanguageCode(languageCode)
					.withVoice(name)
					.withText(adaptedSentence)
					.build();
			
			requestUuid = mRequestScheduler.add(speechRequest);
			
		} catch (Throwable e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}
		
		// we loop until the request has not been processed 
		// (google limits to 300 requests per minute or 15000 characters)
		while(isNotDone) {
			
			try {
				
				request = mRequestScheduler.poll(requestUuid);

				BufferedReader br = new BufferedReader(new InputStreamReader(request.send(), "utf-8"));
				StringBuilder response = new StringBuilder();
				String inputLine;
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine.trim());
				}
				br.close();

				// the answer is encoded in base 64, so it must be decoded
				byte[] decodedBytes = Base64.getDecoder().decode(response.toString().substring(18, response.length()-2));

				AudioBuffer b = bufferAllocator.allocateBuffer(decodedBytes.length);
				b.data = decodedBytes;
				result.add(b);
				
				isNotDone = false;

			} catch (Throwable e1) {
				
				try {
					if (request.getConnection().getResponseCode() == 429) {
						// if the error "too many requests" is raised
						requestUuid = mRequestScheduler.add(request);
						mRequestScheduler.delay(requestUuid);
					}
					else {
						SoundUtil.cancelFootPrint(result, bufferAllocator);
						StringWriter sw = new StringWriter();
						e1.printStackTrace(new PrintWriter(sw));
						throw new SynthesisException(e1);
					}
				} catch (Exception e2) {
					SoundUtil.cancelFootPrint(result, bufferAllocator);
					StringWriter sw = new StringWriter();
					e2.printStackTrace(new PrintWriter(sw));
					throw new SynthesisException(e2);
				}
				
			}
			
		}

		return result;
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return mAudioFormat;
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException,
	InterruptedException {

		Collection<Voice> result = new ArrayList<Voice>();
		
		GoogleRestRequest voicesRequest = null;
		GoogleRestRequest request = null;
		UUID requestUuid = null;
		boolean isNotDone = true;
		
		try {
			
			voicesRequest = mRequestBuilder.newRequest()
					.withAction(Action.VOICES)
					.build();
			
			requestUuid = mRequestScheduler.add(voicesRequest);
			
		} catch (Throwable e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}
		
		// we loop until the request has not been processed 
		// (google limits to 300 requests per minute or 15000 characters)
		while(isNotDone) {
			
			try {
				
				request = mRequestScheduler.poll(requestUuid);
				
				BufferedReader br = new BufferedReader(new InputStreamReader(request.send(), "utf-8"));
				StringBuilder response = new StringBuilder();
				String inputLine;
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine.trim());
				}
				br.close();
				
				// voice name pattern
				Pattern p = Pattern .compile("[a-z]+-[A-Z]+-[a-z A-Z]+-[A-Z]");
				
				// we retrieve the names of the voices in the response returned by the API
				Matcher m = p.matcher(response);

				while (m.find())
					result.add(new Voice(getProvider().getName(),response.substring(m.start(), m.end())));

				isNotDone = false;

			} catch (Throwable e1) {
				
				try {
					if (request.getConnection().getResponseCode() == 429) {
						// if the error "too many requests" is raised
						requestUuid = mRequestScheduler.add(request);
						mRequestScheduler.delay(requestUuid);
					}
					else {
						throw new SynthesisException(e1.getMessage(), e1.getCause());
					}
				} catch (Exception e2) {
					throw new SynthesisException(e2.getMessage(), e2.getCause());
				}
				
			}

		}

		return result;

	}

	@Override
	public int getOverallPriority() {
		return mPriority;
	}

	@Override
	public TTSResource allocateThreadResources() throws SynthesisException,
	InterruptedException {
		return new TTSResource();
	}
	
	@Override
	public int expectedMillisecPerWord() {
		return 64000;
	}

}