package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
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
import org.daisy.pipeline.tts.google.impl.RequestScheduler.TRequest;

public class GoogleRestTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private RequestScheduler mRequestScheduler;
	private String mApiKey;
	private int mPriority;
	
	public GoogleRestTTSEngine(GoogleTTSService googleService, String apiKey, AudioFormat audioFormat, 
			RequestScheduler requestScheduler, int priority) {
		super(googleService);
		mApiKey = "AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM";
		mPriority = priority;
		mAudioFormat = audioFormat;
		mRequestScheduler = requestScheduler;
	}

	@Override
	public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
			Voice voice, TTSResource threadResources, AudioBufferAllocator bufferAllocator, boolean retry)
					throws SynthesisException,InterruptedException, MemoryException {

		Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();

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
			indexOfSecondHyphen = voice.name.indexOf('-', voice.name.indexOf('-') + 1);
			languageCode = '"' + voice.name.substring(0, indexOfSecondHyphen) + '"';
			name = '"' + voice.name + '"';
		}
		else {
			languageCode = '"' + "en-GB" + '"';
			name = '"' + "en-GB-Standard-A" + '"';
		}

		try {
			
			UUID requestID = mRequestScheduler.addRequest(new TRequest(sentence.length(), 300, 15000));
			mRequestScheduler.getRequest(requestID);

			URL url = new URL("https://texttospeech.googleapis.com/v1/text:synthesize?key=" + mApiKey);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("POST");
			con.setRequestProperty("Content-Type", "application/json; utf-8");
			con.setRequestProperty("Accept", "application/json");
			con.setDoOutput(true);

			String jsonInputString =
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
			
			BufferedReader br = new BufferedReader(
					new InputStreamReader(con.getInputStream(), "utf-8"));
			StringBuilder response = new StringBuilder();
			String inputLine;
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine.trim());
			}
			br.close();

			byte[] decodedBytes = Base64.getDecoder().decode(response.toString().substring(18, response.length()-2));

			AudioBuffer b = bufferAllocator.allocateBuffer(decodedBytes.length);
			b.data = decodedBytes;
			result.add(b);

		} catch (Throwable e) {
			SoundUtil.cancelFootPrint(result, bufferAllocator);
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			throw new SynthesisException(e);
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
		
		try {
			
			UUID requestID = mRequestScheduler.addRequest(new TRequest(0, 300, 15000));
			mRequestScheduler.getRequest(requestID);

			URL url = new URL("https://texttospeech.googleapis.com/v1/voices?key=" + mApiKey);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			
			BufferedReader br = new BufferedReader(
					new InputStreamReader(con.getInputStream(), "utf-8"));
			StringBuilder response = new StringBuilder();
			String inputLine;
			while ((inputLine = br.readLine()) != null) {
				response.append(inputLine.trim());
			}
			br.close();

			Pattern p = Pattern .compile("[a-z]+-[A-Z]+-[a-z A-Z]+-[A-Z]");
			Matcher m = p.matcher(response);
			
			while (m.find())
				result.add(new Voice(getProvider().getName(),response.substring(m.start(), m.end())));

		} catch (Throwable e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
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

	/*public static void main (String[] args) throws IOException, InterruptedException {

		URL url;
		HttpURLConnection con = null;
		BufferedReader br;
		StringBuilder response;
		String inputLine;

		for(int i = 0; i < 500; i++) {
			
			System.out.println(i);

			boolean t = true;

			while(t) {

				try {
					url = new URL("https://texttospeech.googleapis.com/v1/voices?key=" + "AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM");
					con = (HttpURLConnection) url.openConnection();
					con.setRequestMethod("GET");

					br = new BufferedReader(
							new InputStreamReader(con.getInputStream(), "utf-8"));
					response = new StringBuilder();
					while ((inputLine = br.readLine()) != null) {
						response.append(inputLine.trim());
					}
					br.close();
					t = false;
				} catch (IOException e) {
					if (con.getResponseCode() == 429) {
						System.out.println("HELLO");
						Thread.sleep(60000);
					}
				}

			}
			
		}


	}*/

}