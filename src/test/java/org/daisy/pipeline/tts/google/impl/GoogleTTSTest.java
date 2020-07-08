package org.daisy.pipeline.tts.google.impl;

import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.StraightBufferAllocator;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import org.junit.Assert;
import org.junit.Test;

public class GoogleTTSTest {

	static AudioBufferAllocator BufferAllocator = new StraightBufferAllocator();

	private static int getSize(Collection<AudioBuffer> buffers) {
		int res = 0;
		for (AudioBuffer buf : buffers) {
			res += buf.size;
		}
		return res;
	}

	private static GoogleRestTTSEngine allocateEngine() throws Throwable {
		GoogleTTSService s = new GoogleTTSService();
		return (GoogleRestTTSEngine) s.newEngine(new HashMap<String, String>());
	}
	
	@Test
	public void convertToIntWithGivenParams() throws Throwable {
		Map<String, String> params = new HashMap<>();
		params.put("org.daisy.pipeline.tts.google.samplerate", "24000");
		GoogleTTSService s = new GoogleTTSService();
		s.newEngine(params);
	}
	
	@Test(expected=SynthesisException.class)
	public void convertToIntWithNotValidParams() throws Throwable {
		Map<String, String> params = new HashMap<>();
		params.put("org.daisy.pipeline.tts.google.samplerate", "240s0T0");
		GoogleTTSService s = new GoogleTTSService();
		s.newEngine(params);
	}

	@Test
	public void getVoiceInfo() throws Throwable {
		Collection<Voice> voices = allocateEngine().getAvailableVoices();
		Assert.assertTrue(voices.size() > 5);
	}

	@Test
	public void speakEasy() throws Throwable {
		GoogleRestTTSEngine engine = allocateEngine();

		TTSResource resource = engine.allocateThreadResources();
		Collection<AudioBuffer> li = engine.synthesize("<s>this is a test</s>", null, null,
		        resource, BufferAllocator, false);
		engine.releaseThreadResources(resource);

		Assert.assertTrue(getSize(li) > 2000);
	}
	
	@Test
	public void speakEasyWithVoiceNotNull() throws Throwable {
		GoogleRestTTSEngine engine = allocateEngine();

		TTSResource resource = engine.allocateThreadResources();
		Collection<AudioBuffer> li = engine.synthesize("<s>this is a test</s>", null, new Voice("google", "en-GB-Standard-B"),
		        resource, BufferAllocator, false);
		engine.releaseThreadResources(resource);

		Assert.assertTrue(getSize(li) > 2000);
	}

	@Test
	public void speakWithVoices() throws Throwable {
		GoogleRestTTSEngine engine = allocateEngine();
		TTSResource resource = engine.allocateThreadResources();

		Set<Integer> sizes = new HashSet<Integer>();
		int totalVoices = 0;
		Iterator<Voice> ite = engine.getAvailableVoices().iterator();
		while (ite.hasNext()) {
			Voice v = ite.next();
			Collection<AudioBuffer> li = engine.synthesize("small test", null, v, resource,
				       BufferAllocator, false);

			sizes.add(getSize(li) / 4); //div 4 helps being more robust to tiny differences
			totalVoices++;
		}
		engine.releaseThreadResources(resource);

		//this number will be very low if the voice names are not properly retrieved
		float diversity = Float.valueOf(sizes.size()) / totalVoices;

		Assert.assertTrue(diversity > 0.4);
	}

	@Test
	public void speakUnicode() throws Throwable {
		GoogleRestTTSEngine engine = allocateEngine();
		TTSResource resource = engine.allocateThreadResources();
		Collection<AudioBuffer> li = engine.synthesize(
		        "<s>𝄞𝄞𝄞𝄞 水水水水水 𝄞水𝄞水𝄞水𝄞水 test 国Ø家Ť标准 ĜæŘ ß ŒÞ ๕</s>", null, null,
		        resource, BufferAllocator, false);
		engine.releaseThreadResources(resource);

		Assert.assertTrue(getSize(li) > 2000);
	}

	@Test
	public void multiSpeak() throws Throwable {
		final GoogleRestTTSEngine engine = allocateEngine();

		final int[] sizes = new int[16];
		Thread[] threads = new Thread[sizes.length];
		for (int i = 0; i < threads.length; ++i) {
			final int j = i;
			threads[i] = new Thread() {
				public void run() {
					TTSResource resource = null;
					try {
						resource = engine.allocateThreadResources();
					} catch (SynthesisException | InterruptedException e) {
						return;
					}

					Collection<AudioBuffer> li = null;
					for (int k = 0; k < 16; ++k) {
						try {
							li = engine.synthesize("<s>small test</s>", null, null, resource, BufferAllocator, false);

						} catch (SynthesisException | InterruptedException | MemoryException e) {
							e.printStackTrace();
							break;
						}
						sizes[j] += getSize(li);
					}
					try {
						engine.releaseThreadResources(resource);
					} catch (SynthesisException | InterruptedException e) {
					}
				}
			};
		}

		for (Thread th : threads)
			th.start();

		for (Thread th : threads)
			th.join();

		for (int size : sizes) {
			Assert.assertEquals(sizes[0], size);
		}
	}
	
	@Test(expected=SynthesisException.class)
	public void tooBigSentence() throws Throwable {
		String sentence = "";
		for (int i = 0 ; i < 5001; i++) {
			sentence = sentence + 'a';
		}
		GoogleRestTTSEngine engine = allocateEngine();
		TTSResource resource = engine.allocateThreadResources();
		engine.synthesize(sentence, null, null,resource, BufferAllocator, false);
		engine.releaseThreadResources(resource);
	}
	
	@Test
	public void adaptedSentence() throws Throwable {
		String sentence = "I can pause <break time=\"3s\"/>.";
		GoogleRestTTSEngine engine = allocateEngine();
		TTSResource resource = engine.allocateThreadResources();
		engine.synthesize(sentence, null, null,resource, BufferAllocator, false);
		engine.releaseThreadResources(resource);
	}
	
}
