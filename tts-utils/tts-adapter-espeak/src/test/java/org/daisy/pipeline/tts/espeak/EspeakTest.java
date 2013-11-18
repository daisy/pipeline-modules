package org.daisy.pipeline.tts.espeak;

import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.Set;

import org.daisy.pipeline.tts.TTSService;
import org.daisy.pipeline.tts.TTSService.RawAudioBuffer;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.TTSService.Voice;
import org.junit.Assert;
import org.junit.Test;

public class EspeakTest {
	@Test
	public void getVoiceInfo() throws SynthesisException {
		TTSService service = new ESpeakBinTTS();
		service.initialize();
		Collection<Voice> voices = service.getAvailableVoices();
		Assert.assertTrue(voices.size() > 5);
	}

	@Test
	public void speakEasy() throws SynthesisException {
		ESpeakBinTTS service = new ESpeakBinTTS();
		service.initialize();

		RawAudioBuffer rab = new RawAudioBuffer();
		rab.output = new byte[512 * 1024];
		rab.offsetInOutput = 0;

		Object resource = service.allocateThreadResources();
		service.synthesize("<s>this is a test</s>", rab, resource, null, null);
		service.releaseThreadResources(resource);

		Assert.assertTrue(rab.offsetInOutput > 2000);
	}

	@Test
	public void speakWithVoices() throws SynthesisException {
		ESpeakBinTTS service = new ESpeakBinTTS();
		service.initialize();
		Object resource = service.allocateThreadResources();

		RawAudioBuffer rab = new RawAudioBuffer();
		rab.output = new byte[512 * 1024];

		Set<Integer> sizes = new HashSet<Integer>();
		int totalVoices = 0;
		Iterator<Voice> ite = service.getAvailableVoices().iterator();
		while (ite.hasNext()) {
			Voice v = ite.next();
			rab.offsetInOutput = 0;
			service.synthesize("<s><voice name=\"" + v.name
			        + "\">small test</voice></s>", rab, resource, null, null);
			sizes.add(rab.offsetInOutput / 4); //div 4 helps being more robust to tiny differences
			totalVoices++;
		}
		service.releaseThreadResources(resource);

		//this number will be very low if the voice names are not properly retrieved
		float diversity = Float.valueOf(sizes.size()) / totalVoices;

		Assert.assertTrue(diversity > 0.4);
	}

	@Test
	public void speakUnicode() throws SynthesisException {
		ESpeakBinTTS service = new ESpeakBinTTS();
		service.initialize();

		RawAudioBuffer rab = new RawAudioBuffer();
		rab.output = new byte[512 * 1024];
		rab.offsetInOutput = 0;

		Object resource = service.allocateThreadResources();
		service.synthesize(
		        "<s>𝄞𝄞𝄞𝄞 水水水水水 𝄞水𝄞水𝄞水𝄞水 test 国Ø家Ť标准 ĜæŘ ß ŒÞ ๕</s>",
		        rab, resource, null, null);
		service.releaseThreadResources(resource);

		Assert.assertTrue(rab.offsetInOutput > 2000);
	}

	@Test
	public void multiSpeak() throws SynthesisException, InterruptedException {
		final ESpeakBinTTS service = new ESpeakBinTTS();
		service.initialize();

		final int[] sizes = new int[16];
		Thread[] threads = new Thread[sizes.length];
		for (int i = 0; i < threads.length; ++i) {
			final int j = i;
			threads[i] = new Thread() {
				public void run() {
					RawAudioBuffer rab = new RawAudioBuffer();
					rab.output = new byte[512 * 1024];
					Object resource = null;
					try {
						resource = service.allocateThreadResources();
					} catch (SynthesisException e) {
						return;
					}

					for (int k = 0; k < 16; ++k) {
						rab.offsetInOutput = 0;
						try {
							service.synthesize("<s>small test</s>", rab,
							        resource, null, null);
						} catch (SynthesisException e) {
							break;
						}
						sizes[j] += rab.offsetInOutput;
					}
					service.releaseThreadResources(resource);
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
}
