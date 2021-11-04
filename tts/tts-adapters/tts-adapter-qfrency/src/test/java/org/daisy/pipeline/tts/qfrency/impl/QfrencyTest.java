package org.daisy.pipeline.tts.qfrency.impl;

import java.io.StringReader;
import java.util.Collection;

import javax.xml.transform.sax.SAXSource;

import net.sf.saxon.s9api.Processor;
import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.tts.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.StraightBufferAllocator;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

import org.xml.sax.InputSource;

/*
 * Unit test for the Qfrency adapter.
 * You must have a speech server running on localhost to run these tests. You also nead the client program in your path as "qfrency-client". 
 */


public class QfrencyTest {
	QfrencyEngine tts;

	static AudioBufferAllocator BufferAllocator = new StraightBufferAllocator();

	private String format(String str) {
		return str;
	}

	private String format(String str, String speakerName) {
		return "\\voice{" + speakerName + "}" + str;
	}

	static private int getSize(Collection<AudioBuffer> buffers) {
		if (buffers == null)
			return -1;
		int size = 0;
		for (AudioBuffer b : buffers) {
			size += b.size;
		}
		return size;
	}

	@Before
	public void setUp() throws SynthesisException, InterruptedException {
		tts = new QfrencyEngine(new QfrencyService(), "qfrency-client", "localhost", 0);
	}

	@Test
	public void getVoiceNames() throws SynthesisException, InterruptedException {
		Collection<Voice> voices = tts.getAvailableVoices();
		Assert.assertTrue("some voices must be found", voices.size() > 0);
	}

	public Voice getVoice() throws SynthesisException, InterruptedException {
		Collection<Voice> voices = tts.getAvailableVoices();
		if (voices.size()>0)
			return voices.iterator().next();
		return null;
	}
	
	@Test
	public void simpleSpeak() throws SynthesisException, InterruptedException, MemoryException, SaxonApiException {
		TTSResource r = tts.allocateThreadResources();
		Voice voice = getVoice();
		Assert.assertTrue("At least one voice must be available", voice!=null);
		int size = getSize(
			tts.synthesize(
				parseSSML("<s xmlns=\"http://www.w3.org/2001/10/synthesis\">this is a test<s>"),
				voice, r, null, null, BufferAllocator, true));
		tts.releaseThreadResources(r);

		Assert.assertTrue("audio output must be big enough", size > 2000);
	}

	private static final Processor proc = new Processor(false);

	private static XdmNode parseSSML(String ssml) throws SaxonApiException {
		return proc.newDocumentBuilder().build(new SAXSource(new InputSource(new StringReader(ssml))));
	}
}
