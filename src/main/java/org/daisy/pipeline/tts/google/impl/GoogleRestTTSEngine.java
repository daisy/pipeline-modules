package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.shell.CommandRunner;
import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.MarklessTTSEngine;
import org.daisy.pipeline.tts.SoundUtil;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;
import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GoogleRestTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private final static int MIN_CHUNK_SIZE = 2048;
	private int mPriority;
	private final static Logger mLogger = LoggerFactory.getLogger(GoogleTTSEngine.class);
	private String[] mCmd;
	
	public GoogleRestTTSEngine(GoogleTTSService googleService, String eSpeakPath, int priority) {
		super(googleService);
		mPriority = priority;
		mCmd = new String[]{
		        eSpeakPath, "-m", "--stdout", "--stdin"
		};
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

		/*String apiKey = "AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM";

		CloseableHttpClient httpClient = HttpClients.createDefault();

		try {

			HttpGet request = new HttpGet("https://texttospeech.googleapis.com/v1/voices?key=" + apiKey);

			CloseableHttpResponse response = httpClient.execute(request);

			HttpEntity entity = response.getEntity();

			if (entity != null) {

				String res = EntityUtils.toString(entity);

				JSONObject jsonObject = new JSONObject(res);
				JSONArray array = new JSONArray(jsonObject.getString("voices"));

				for (int i = 0; i < array.length(); i++) {
					JSONObject obj = new JSONObject(array.getString(i));
					Voice voice = new Voice("google", obj.getString("name"));
					result.add(voice);
				}

			}

			response.close();

			httpClient.close();


		} catch (Throwable e) {

			e.printStackTrace();

		}*/

		try {

			URL url = new URL("https://texttospeech.googleapis.com/v1/voices?key=AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM");
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			BufferedReader in = new BufferedReader(
					new InputStreamReader(con.getInputStream()));
			String inputLine;
			String content = "";
			while ((inputLine = in.readLine()) != null) {
				content = content + inputLine;
			}
			in.close();
			JSONObject jsonObject = new JSONObject(content);
			JSONArray array = new JSONArray(jsonObject.getString("voices"));

			for (int i = 0; i < array.length(); i++) {
				JSONObject obj = new JSONObject(array.getString(i));
				Voice voice = new Voice("google", obj.getString("name"));
				result.add(voice);
			}

		} catch (Throwable e) {
			e.printStackTrace();
		}
		
		//result.add(new Voice("google","BONJOUR"));

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

	/*public static void main (String[] args) {

		HttpRequestFactory requestFactory
		= new NetHttpTransport().createRequestFactory();
		HttpRequest request = requestFactory.buildGetRequest(
				new GenericUrl("https://texttospeech.googleapis.com/v1/voices?key=AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM"));
		String rawResponse = request.execute().parseAsString();
		
		Collection<Voice> result = new ArrayList<Voice>();

		JSONObject jsonObject = new JSONObject(rawResponse);
		JSONArray array = new JSONArray(jsonObject.getString("voices"));
		
		for (int i = 0; i < array.length(); i++) {
			JSONObject obj = new JSONObject(array.getString(i));
			Voice voice = new Voice("google", obj.getString("name"));
			result.add(voice);
		}
		
		for (Voice voice : result) {
			System.out.println("{ engine : " + voice.engine + ", name : " + voice.name + " }");
		}
		
		HttpRequestFactory requestFactory
		= new NetHttpTransport().createRequestFactory();
		String jsonInputString = "{\"input\":{\"text\":\"Android is a mobile operating system developed by Google, based on the Linux kernel and designed primarily for touchscreen mobile devices such as smartphones and tablets.\"},\"voice\":{\"languageCode\":\"en-gb\",\"name\":\"en-GB-Standard-A\",\"ssmlGender\":\"FEMALE\"},\"audioConfig\":{\"audioEncoding\":\"MP3\"}}";
		JSONObject jsonObject = new JSONObject(jsonInputString);
		JsonFactory jsonFactory = JacksonFactory.getDefaultInstance();
		JsonHttpContent jsonContent = new JsonHttpContent(jsonFactory , jsonObject);
		HttpRequest request = requestFactory.buildPostRequest(
				new GenericUrl("https://texttospeech.googleapis.com/v1/text:synthesize?key=AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM"), jsonContent);
		String rawResponse = request.execute().parseAsString();
		System.out.println(rawResponse);

		Collection<Voice> result = new ArrayList<Voice>();

		try {

			URL url = new URL("https://texttospeech.googleapis.com/v1/voices?key=AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM");
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("GET");
			BufferedReader in = new BufferedReader(
					new InputStreamReader(con.getInputStream()));
			String inputLine;
			String content = "";
			while ((inputLine = in.readLine()) != null) {
				content = content + inputLine;
			}
			in.close();
			JSONObject jsonObject = new JSONObject(content);
			JSONArray array = new JSONArray(jsonObject.getString("voices"));

			for (int i = 0; i < array.length(); i++) {
				JSONObject obj = new JSONObject(array.getString(i));
				Voice voice = new Voice("google", obj.getString("name"));
				result.add(voice);
			}

			for (Voice voice : result) {
				System.out.println("{ engine : " + voice.engine + ", name : " + voice.name + " }");
			}

		} catch (Throwable e) {
			e.printStackTrace();
		}

	}*/

}