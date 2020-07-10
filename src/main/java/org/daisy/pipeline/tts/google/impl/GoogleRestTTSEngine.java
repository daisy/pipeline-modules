package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collection;
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

public class GoogleRestTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private RequestScheduler mRequestScheduler;
	private String mApiKey;
	private int mPriority;
	
	public GoogleRestTTSEngine(GoogleTTSService googleService, String apiKey, AudioFormat audioFormat, 
			RequestScheduler requestScheduler, int priority) {
		super(googleService);
		mApiKey = apiKey;
		mPriority = priority;
		mAudioFormat = audioFormat;
		mRequestScheduler = requestScheduler;
	}
	
	@Override
	public int expectedMillisecPerWord() {
		return 64000;
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
		
		adaptedSentence = '"' + adaptedSentence + '"';
		
		String languageCode;
		String name;
		int indexOfSecondHyphen;

		if (voice != null) {
			//recovery of the language code in the name of the voice
			indexOfSecondHyphen = voice.name.indexOf('-', voice.name.indexOf('-') + 1);
			languageCode = '"' + voice.name.substring(0, indexOfSecondHyphen) + '"';
			name = '"' + voice.name + '"';
		}
		else {
			// by default the voice is set to English
			languageCode = '"' + "en-GB" + '"';
			name = '"' + "en-GB-Standard-A" + '"';
		}
		
		URL url;
		HttpURLConnection con = null;
		String jsonInputString;
		BufferedReader br;
		StringBuilder response;
		String inputLine;
		byte[] decodedBytes;
		AudioBuffer b;
		
		boolean isNotDone = true;
		
		// we loop until the request has not been processed 
		// (google limits to 300 requests per minute or 15000 characters)
		while(isNotDone) {
			
			try {
				
				url = new URL("https://texttospeech.googleapis.com/v1/text:synthesize?key=" + mApiKey);
				con = (HttpURLConnection) url.openConnection();
				con.setRequestMethod("POST");
				con.setRequestProperty("Content-Type", "application/json; utf-8");
				con.setRequestProperty("Accept", "application/json");
				con.setDoOutput(true);

				// building the json query
				jsonInputString =
						"  { \"input\":{" + 
								"    \"ssml\":" + adaptedSentence + 
								"  }," + 
								"  \"voice\":{" + 
								"    \"languageCode\":" + languageCode + "," + 
								"    \"name\":" + name + 
								"  }," + 
								"  \"audioConfig\":{" + 
								"    \"audioEncoding\":\"LINEAR16\"," +
								"    \"sampleRateHertz\":" + mAudioFormat.getSampleRate() +
								"  }}";


				try(OutputStream os = con.getOutputStream()) {
					byte[] input = jsonInputString.getBytes("utf-8");
					os.write(input, 0, input.length);           
				}

				br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"));
				response = new StringBuilder();
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine.trim());
				}
				br.close();

				// the answer is encoded in base 64, so it must be decoded
				decodedBytes = Base64.getDecoder().decode(response.toString().substring(18, response.length()-2));

				b = bufferAllocator.allocateBuffer(decodedBytes.length);
				b.data = decodedBytes;
				result.add(b);
				
				isNotDone = false;

			} catch (Throwable e1) {
				
				try {
					if (con.getResponseCode() == 429) {
						// if the error "too many requests is raised
						mRequestScheduler.sleep();
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
		
		URL url;
		HttpURLConnection con = null;
		BufferedReader br;
		StringBuilder response;
		String inputLine;
		// voice name pattern
		Pattern p = Pattern .compile("[a-z]+-[A-Z]+-[a-z A-Z]+-[A-Z]");
		Matcher m;

		boolean isNotDone = true;
		
		// we loop until the request has not been processed 
		// (google limits to 300 requests per minute or 15000 characters)
		while(isNotDone) {
			
			try {

				url = new URL("https://texttospeech.googleapis.com/v1/voices?key=" + mApiKey);
				con = (HttpURLConnection) url.openConnection();
				con.setRequestMethod("GET");

				br = new BufferedReader(new InputStreamReader(con.getInputStream(), "utf-8"));
				response = new StringBuilder();
				while ((inputLine = br.readLine()) != null) {
					response.append(inputLine.trim());
				}
				br.close();
				
				// we retrieve the names of the voices in the response returned by the API
				m = p.matcher(response);

				while (m.find())
					result.add(new Voice(getProvider().getName(),response.substring(m.start(), m.end())));

				isNotDone = false;

			} catch (Throwable e1) {
				
				try {
					if (con.getResponseCode() == 429) {
						// if the error "too many requests is raised
						mRequestScheduler.sleep();
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

}