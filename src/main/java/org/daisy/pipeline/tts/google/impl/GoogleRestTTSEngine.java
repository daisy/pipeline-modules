package org.daisy.pipeline.tts.google.impl;

import java.io.BufferedReader;
import java.io.ByteArrayInputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FileWriter;
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
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class GoogleRestTTSEngine extends MarklessTTSEngine {

	private AudioFormat mAudioFormat;
	private final static int MIN_CHUNK_SIZE = 2048;
	private String mApiKey;
	private int mPriority;
	private final static Logger mLogger = LoggerFactory.getLogger(GoogleTTSEngine.class);

	public GoogleRestTTSEngine(GoogleTTSService googleService, String apiKey, int priority) {
		super(googleService);
		mApiKey = apiKey;
	}

	@Override
	public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
			Voice voice, TTSResource threadResources, AudioBufferAllocator bufferAllocator, boolean retry)
					throws SynthesisException,InterruptedException, MemoryException {

		Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();

		String adaptedSentence = "";

		char c;

		for (int i = 0; i < sentence.length(); i++) {
			c = sentence.charAt(i);
			if (c == '"') {
				adaptedSentence = adaptedSentence + '\\' + c;
			}
			else {
				adaptedSentence = adaptedSentence + c;
			}
		}

		adaptedSentence = '"' + adaptedSentence + '"';

		String languageCode = '"' + voice.name.substring(0, 4) + '"';
		String name = '"' + voice.name + '"';
		String ssmlGender = '"' + "FEMALE" + '"';

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
							"    \"name\":" + name + "," + 
							"    \"ssmlGender\":" + ssmlGender + 
							"  }," + 
							"  \"audioConfig\":{" + 
							"    \"audioEncoding\":\"MP3\"" + 
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

	/*public static void main (String[] args) throws IOException {

		String apiKey = "AIzaSyA2vhAI52241mAkixcnSfz8AJkS8cpaHVM";

		String sentence = "<speak>Salut</speak>";

		String tmp = '"' + sentence + '"';

		String languageCode = "\"en-gb\"";
		String name = "\"en-GB-Standard-A\"";
		String ssmlGender = "\"FEMALE\"";

		try {

			URL url = new URL("https://texttospeech.googleapis.com/v1/text:synthesize?key=" + apiKey);
			HttpURLConnection con = (HttpURLConnection) url.openConnection();
			con.setRequestMethod("POST");
			con.setRequestProperty("Content-Type", "application/json; utf-8");
			con.setRequestProperty("Accept", "application/json");
			con.setDoOutput(true);

			String jsonInputString =
					"  { \"input\":{" + 
							"    \"ssml\":" + tmp + 
							"  }," + 
							"  \"voice\":{" + 
							"    \"languageCode\":" + languageCode + "," + 
							"    \"name\":" + name + "," + 
							"    \"ssmlGender\":" + ssmlGender + 
							"  }," + 
							"  \"audioConfig\":{" + 
							"    \"audioEncoding\":\"MP3\"" + 
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

				FileWriter myWriter = new FileWriter("synthesize-output-base64.txt");
				myWriter.write(response.toString().substring(18, response.length()-2));
				myWriter.close();

				byte[] decodedBytes = Base64.getDecoder().decode(response.toString().substring(18, response.length()-2));

				String fileName = "out.mp3";
				File dest = new File(fileName);
				dest.createNewFile();

				ByteArrayInputStream sourceFile = new ByteArrayInputStream(decodedBytes);

				FileOutputStream destinationFile =  new FileOutputStream(dest);

				byte buffer[]=new byte[512*1024];
				int nbLecture;

				while( (nbLecture = sourceFile.read(buffer)) != -1 ) {
					destinationFile.write(buffer, 0, nbLecture);
				}

				destinationFile.close();

				sourceFile.close();

			} catch (Throwable e) {
				e.printStackTrace();
			}

		} finally {

		}

	}*/

}