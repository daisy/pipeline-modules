package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedInputStream;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.MarklessTTSEngine;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import com.google.api.gax.core.CredentialsProvider;
import com.google.api.gax.core.FixedCredentialsProvider;
import com.google.auth.oauth2.ServiceAccountCredentials;
import com.google.cloud.texttospeech.v1.ListVoicesRequest;
import com.google.cloud.texttospeech.v1.ListVoicesResponse;
import com.google.cloud.texttospeech.v1.TextToSpeechClient;
import com.google.cloud.texttospeech.v1.TextToSpeechSettings;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.daisy.common.shell.CommandRunner;

public class GoogleTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private String[] mCmd;
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

		try {
			new CommandRunner(mCmd)
			.feedInput(sentence.getBytes("utf-8"))
			// read the wave on the standard output
			.consumeOutput(stream -> {
				BufferedInputStream in = new BufferedInputStream(stream);
				AudioInputStream fi = AudioSystem.getAudioInputStream(in);
				if (mAudioFormat == null)
					mAudioFormat = fi.getFormat();
				while (true) {
					AudioBuffer b = bufferAllocator
							.allocateBuffer(MIN_CHUNK_SIZE + fi.available());
					int ret = fi.read(b.data, 0, b.size);
					if (ret == -1) {
						// note: perhaps it would be better to call allocateBuffer()
						// somewhere else in order to avoid this extra call:
						bufferAllocator.releaseBuffer(b);
						break;
					}
					b.size = ret;
					result.add(b);
				}
				fi.close();
			})
			.consumeError(mLogger)
			.run();
		} catch (MemoryException|InterruptedException e) {
			SoundUtil.cancelFootPrint(result, bufferAllocator);
			throw e;
		} catch (Throwable e) {
			SoundUtil.cancelFootPrint(result, bufferAllocator);
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			throw new SynthesisException(e);
		}

		/*
		// Instantiates a client
	    try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {
	      // Set the text input to be synthesized
	      SynthesisInput input = SynthesisInput.newBuilder().setText(sentence).build();

	      // Build the voice request, select the language code ("en-US") and the ssml voice gender
	      // ("neutral")
	      VoiceSelectionParams voiceSelectionParams =
	          VoiceSelectionParams.newBuilder()
	              .setLanguageCode("en-US")
	              .setSsmlGender(SsmlVoiceGender.NEUTRAL)
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

	      AudioBuffer b = audioContents.toByteArray();

	      result.add(b);

	    } catch (IOException e1) {
			// TODO Auto-generated catch block
			e1.printStackTrace();
		}*/


		return result;
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return mAudioFormat;
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException,
	InterruptedException {

		Collection<Voice> result = new ArrayList<Voice>();;	

		CredentialsProvider credentialsProvider = null;

		TextToSpeechSettings settings = null;

		if (mJsonPath != "") {

			try {
				credentialsProvider = FixedCredentialsProvider.create(ServiceAccountCredentials.fromStream(new FileInputStream(mJsonPath)));
				settings = TextToSpeechSettings.newBuilder().setCredentialsProvider(credentialsProvider).build();
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {

				ListVoicesRequest request = ListVoicesRequest.getDefaultInstance();

				ListVoicesResponse response = textToSpeechClient.listVoices(request);
				List<com.google.cloud.texttospeech.v1.Voice> voices = response.getVoicesList();


				for (com.google.cloud.texttospeech.v1.Voice voice : voices) {	
					result.add(new Voice("google", voice.getName()));
				}

			} catch (IOException e) { 
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

		}

		else {
			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {

				ListVoicesRequest request = ListVoicesRequest.getDefaultInstance();

				ListVoicesResponse response = textToSpeechClient.listVoices(request);
				List<com.google.cloud.texttospeech.v1.Voice> voices = response.getVoicesList();


				for (com.google.cloud.texttospeech.v1.Voice voice : voices) {	
					result.add(new Voice("google", voice.getName()));
				}

			} catch (IOException e) {	  
				throw new SynthesisException(e.getMessage(), e.getCause());	  
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



	/*public static void main (String[] args) throws SynthesisException {

		String mJsonPath = "";

		Collection<Voice> result = new ArrayList<Voice>();;	

		CredentialsProvider credentialsProvider = null;

		TextToSpeechSettings settings = null;

		if (mJsonPath != "") {

			try {
				credentialsProvider = FixedCredentialsProvider.create(ServiceAccountCredentials.fromStream(new FileInputStream(mJsonPath)));
				settings = TextToSpeechSettings.newBuilder().setCredentialsProvider(credentialsProvider).build();
			} catch (IOException e) {
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create(settings)) {

				ListVoicesRequest request = ListVoicesRequest.getDefaultInstance();

				ListVoicesResponse response = textToSpeechClient.listVoices(request);
				List<com.google.cloud.texttospeech.v1.Voice> voices = response.getVoicesList();


				for (com.google.cloud.texttospeech.v1.Voice voice : voices) {	
					result.add(new Voice("google", voice.getName()));
				}

			} catch (IOException e) { 
				throw new SynthesisException(e.getMessage(), e.getCause());
			}

		}

		else {
			try (TextToSpeechClient textToSpeechClient = TextToSpeechClient.create()) {

				ListVoicesRequest request = ListVoicesRequest.getDefaultInstance();

				ListVoicesResponse response = textToSpeechClient.listVoices(request);
				List<com.google.cloud.texttospeech.v1.Voice> voices = response.getVoicesList();


				for (com.google.cloud.texttospeech.v1.Voice voice : voices) {	
					result.add(new Voice("google", voice.getName()));
				}

			} catch (IOException e) {	  
				throw new SynthesisException(e.getMessage(), e.getCause());	  
			}

		}

		for (Voice voice : result) {
			System.out.println("* {engine:google, name:" + voice.name + "} by google-cli");
		}

	}*/

}
	