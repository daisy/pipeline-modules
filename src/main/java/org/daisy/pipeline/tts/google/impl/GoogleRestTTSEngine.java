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
	private String mApiKey;
	private int mPriority;

	public GoogleRestTTSEngine(GoogleTTSService googleService, String apiKey, AudioFormat audioFormat, int priority) {
		super(googleService);
		mApiKey = apiKey;
		mPriority = priority;
		mAudioFormat = audioFormat;
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
		
		if (voice != null) {
			languageCode = '"' + voice.name.substring(0, 4) + '"';
			name = '"' + voice.name + '"';
		}
		else {
			languageCode = '"' + "en-GB" + '"';
			name = '"' + "en-GB-Standard-A" + '"';
		}

		try {

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
							"    \"audioEncoding\":\"MP3\"," +
							"    \"sampleRateHertz\":" + mAudioFormat.getSampleRate() +
							"  }}";

			try(OutputStream os = con.getOutputStream()) {
				byte[] input = jsonInputString.getBytes("utf-8");
				os.write(input, 0, input.length);           
			}

			try(BufferedReader br = new BufferedReader(
					new InputStreamReader(con.getInputStream(), "utf-8"))) {
				StringBuilder response = new StringBuilder();
				String responseLine = null;
				while ((responseLine = br.readLine()) != null) {
					response.append(responseLine.trim());
				}

				byte[] decodedBytes = Base64.getDecoder().decode(response.toString().substring(18, response.length()-2));
				AudioBuffer b = bufferAllocator.allocateBuffer(decodedBytes.length);
				b.data = decodedBytes;
				result.add(b);	

			}

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

			URL url = new URL("https://texttospeech.googleapis.com/v1/voices?key=" + mApiKey);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			
			BufferedReader in = new BufferedReader(
					new InputStreamReader(con.getInputStream()));
			String inputLine;
			StringBuilder content = new StringBuilder();
			while ((inputLine = in.readLine()) != null) {
				content.append(inputLine);
			}
			in.close();


			Pattern p = Pattern .compile("[a-z][a-z]-[A-Z][A-Z]-[a-z A-Z]+-[A-Z]");
			Matcher m = p.matcher(content);
			
			while (m.find())
				result.add(new Voice(getProvider().getName(),content.substring(m.start(), m.end())));

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

}