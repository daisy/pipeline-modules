package org.daisy.pipeline.tts.google.impl;

import java.io.FileInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.MarklessTTSEngine;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.api.gax.core.CredentialsProvider;
import com.google.api.gax.core.FixedCredentialsProvider;
import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.cloud.texttospeech.v1.AudioConfig;
import com.google.cloud.texttospeech.v1.AudioEncoding;
import com.google.cloud.texttospeech.v1.ListVoicesRequest;
import com.google.cloud.texttospeech.v1.ListVoicesResponse;
import com.google.cloud.texttospeech.v1.SsmlVoiceGender;
import com.google.cloud.texttospeech.v1.SynthesisInput;
import com.google.cloud.texttospeech.v1.SynthesizeSpeechResponse;
import com.google.cloud.texttospeech.v1.TextToSpeechClient;
import com.google.cloud.texttospeech.v1.TextToSpeechSettings;
import com.google.cloud.texttospeech.v1.VoiceSelectionParams;
import com.google.protobuf.ByteString;

public class GoogleTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private String mJsonPath;
	private final static int MIN_CHUNK_SIZE = 2048;
	private int mPriority;
	private final static Logger mLogger = LoggerFactory.getLogger(GoogleTTSEngine.class);
	
	public GoogleTTSEngine(GoogleTTSService googleService, String jsonPath, int priority) {
		super(googleService);
		mJsonPath = jsonPath;
		mPriority = priority;
	}

	@Override
	public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
			Voice voice, TTSResource threadResources, AudioBufferAllocator bufferAllocator, boolean retry)
					throws SynthesisException,InterruptedException, MemoryException {

		Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();

		CredentialsProvider credentialsProvider = null;

		TextToSpeechSettings settings = null;

		SynthesisInput input = SynthesisInput.newBuilder().setSsml(sentence).build();
		
		 VoiceSelectionParams voiceSelectionParams = VoiceSelectionParams.newBuilder()
				.setName(voice.name)
				.setLanguageCode(voice.name.substring(0, 2))
				.setSsmlGender(SsmlVoiceGender.NEUTRAL)
				.build();

		AudioConfig audioConfig =
				AudioConfig.newBuilder().setAudioEncoding(AudioEncoding.MP3).build();

		SynthesizeSpeechResponse response = null;

		if (mJsonPath != "") {

			try {
				credentialsProvider = FixedCredentialsProvider.create(ServiceAccountCredentials.fromStream(new FileInputStream(mJsonPath)));
				settings = TextToSpeechSettings.newBuilder().setCredentialsProvider(credentialsProvider).build();
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {

				response = textToSpeechClient.synthesizeSpeech(input, voiceSelectionParams, audioConfig);

			} catch (IOException e) { 
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

		}

		else {
			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {

				response = textToSpeechClient.synthesizeSpeech(input, voiceSelectionParams, audioConfig);

			} catch (IOException e) {	  
				throw new SynthesisException(e.getMessage(), e.getCause());	  
			}

		}

		ByteString audioContents = response.getAudioContent();

		AudioBuffer b = bufferAllocator.allocateBuffer(MIN_CHUNK_SIZE + audioContents.size());

		b.data = audioContents.toByteArray();

		result.add(b);


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

		CredentialsProvider credentialsProvider = null;

		TextToSpeechSettings settings = null;

		ListVoicesResponse response;

		ListVoicesRequest request = ListVoicesRequest.getDefaultInstance();

		if (mJsonPath != "") {

			try {
				credentialsProvider = FixedCredentialsProvider.create(ServiceAccountCredentials.fromStream(new FileInputStream(mJsonPath)));
				settings = TextToSpeechSettings.newBuilder().setCredentialsProvider(credentialsProvider).build();
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {

				response = textToSpeechClient.listVoices(request);

			} catch (IOException e) { 
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

		}

		else {
			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {

				response = textToSpeechClient.listVoices(request);

			} catch (IOException e) {	  
				throw new SynthesisException(e.getMessage(), e.getCause());	  
			}

		}

		List<com.google.cloud.texttospeech.v1.Voice> voices = response.getVoicesList();

		for (com.google.cloud.texttospeech.v1.Voice voice : voices) {	
			result.add(new Voice(getProvider().getName(), voice.getName()));
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
	
	/*public static void main (String[] args) throws SynthesisException, MemoryException {

		// Instantiates a client
		try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {
			// Set the text input to be synthesized
			SynthesisInput input = SynthesisInput.newBuilder().setSsml("<speak><p>Bonjour, <pagenum>5</pagenum>, comment <noteref>12</noteref> vas-tu?</p></speak>").build();

			// Build the voice request, select the language code ("en-US") and the ssml voice gender
			// ("neutral")
			VoiceSelectionParams voiceSelectionParams =
					VoiceSelectionParams.newBuilder()
					.setLanguageCode("fr")
					.setSsmlGender(SsmlVoiceGender.MALE)
					.build();

			// Select the type of audio file you want returned
			AudioConfig audioConfig =
					AudioConfig.newBuilder().setAudioEncoding(AudioEncoding.MP3).build();

			// Perform the text-to-speech request on the text input with the selected voice parameters and
			// audio file type
			SynthesizeSpeechResponse response =
					textToSpeechClient.synthesizeSpeech(input, voiceSelectionParams, audioConfig);

			// Get the audio contents from the response
			ByteString audioContents = response.getAudioContent();

			// Write the response to the output file.
			try (OutputStream out = new FileOutputStream("output.mp3")) {
				out.write(audioContents.toByteArray());
				System.out.println("Audio content written to file \"output.mp3\"");
			}


		} catch (IOException e) {
			throw new SynthesisException(e.getMessage(), e.getCause());	  
		}

	}*/

}
	