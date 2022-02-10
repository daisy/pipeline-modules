package org.daisy.pipeline.tts.mock.impl;

import java.io.BufferedInputStream;
import java.net.URL;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Map;

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.file.URLs;
import org.daisy.pipeline.audio.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.MarklessTTSEngine;
import org.daisy.pipeline.tts.TTSEngine;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component(
	name = "mock-tts",
	service = { TTSService.class }
)
public class MockTTS implements TTSService {
	
	final static Logger logger = LoggerFactory.getLogger(MockTTS.class);
	final static URL alexWaveOut = URLs.getResourceFromJAR("/mock-tts/alex.wav", MockTTS.class);
	final static URL vickiWaveOut = URLs.getResourceFromJAR("/mock-tts/vicki.wav", MockTTS.class);
	final static URL daisyPipelineWaveOut = URLs.getResourceFromJAR("/mock-tts/daisy-pipeline.wav", MockTTS.class);
	URL ssmlTransformer;
	
	@Activate
	protected void activate() {
		ssmlTransformer = URLs.getResourceFromJAR("/mock-tts/transform-ssml.xsl", MockTTS.class);
	}
	
	@Override
	public TTSEngine newEngine(Map<String,String> params) throws Throwable {
		return new MarklessTTSEngine(MockTTS.this) {
			
			AudioFormat audioFormat;
			
			@Override
			public Collection<AudioBuffer> synthesize(String sentence, XdmNode xmlSentence,
			                                          Voice voice, TTSResource threadResources,
			                                          AudioBufferAllocator bufferAllocator, boolean retry)
					throws SynthesisException, InterruptedException, MemoryException {
				logger.debug("Synthesizing sentence: " + sentence);
				try {
					Collection<AudioBuffer> result = new ArrayList<AudioBuffer>();
					BufferedInputStream in = new BufferedInputStream(
						(voice.name.equals("alex")
							? MockTTS.alexWaveOut
							: voice.name.equals("vicki")
								? MockTTS.vickiWaveOut
								: MockTTS.daisyPipelineWaveOut).openStream());
					AudioInputStream fi = AudioSystem.getAudioInputStream(in);
					audioFormat = fi.getFormat();
					while (true) {
						AudioBuffer b = bufferAllocator.allocateBuffer(2048 + fi.available());
						int ret = fi.read(b.data, 0, b.size);
						if (ret == -1) {
							bufferAllocator.releaseBuffer(b);
							break; }
						b.size = ret;
						result.add(b); }
					fi.close();
					return result; }
				catch (Exception e) {
					throw new SynthesisException(e); }
			}
			
			@Override
			public AudioFormat getAudioOutputFormat() {
				return audioFormat;
			}
			
			@Override
			public Collection<Voice> getAvailableVoices() throws SynthesisException, InterruptedException {
				List<Voice> voices = new ArrayList<Voice>();
				voices.add(new Voice(getProvider().getName(), "alex"));
				voices.add(new Voice(getProvider().getName(), "vicki"));
				voices.add(new Voice(getProvider().getName(), "foo"));
				return voices;
			}
			
			@Override
			public int getOverallPriority() {
				return 2;
			}
		};
	}
	
	@Override
	public URL getSSMLxslTransformerURL() {
		return ssmlTransformer;
	}
	
	@Override
	public String getName() {
		return "mock-tts";
	}
	
	@Override
	public String getVersion() {
		return "1";
	}
}
