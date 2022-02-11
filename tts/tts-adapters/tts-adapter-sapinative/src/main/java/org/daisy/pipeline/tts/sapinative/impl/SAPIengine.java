package org.daisy.pipeline.tts.sapinative.impl;

import java.io.IOException;
import java.net.URL;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.sound.sampled.AudioFormat;

import net.sf.saxon.s9api.SaxonApiException;
import net.sf.saxon.s9api.XdmNode;

import org.daisy.common.file.URLs;
import org.daisy.pipeline.tts.AudioBuffer;
import org.daisy.pipeline.tts.AudioBufferAllocator;
import org.daisy.pipeline.tts.AudioBufferAllocator.MemoryException;
import org.daisy.pipeline.tts.sapinative.SAPILib;
import org.daisy.pipeline.tts.TTSEngine;
import org.daisy.pipeline.tts.TTSRegistry.TTSResource;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.Voice;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class SAPIengine extends TTSEngine {

	private static final Logger Logger = LoggerFactory.getLogger(SAPIengine.class);
	private static final URL ssmlTransformer = URLs.getResourceFromJAR("/transform-ssml.xsl", SAPIengine.class);

	private final AudioFormat mAudioFormat;
	private final int mOverallPriority;
	private Map<String, Voice> mVoiceFormatConverter = null;

	private static class ThreadResource extends TTSResource {
		long connection;
	}

	public SAPIengine(SAPIservice service, AudioFormat audioFormat, int priority) {
		super(service);
		mAudioFormat = audioFormat;
		mOverallPriority = priority;
	}

	@Override
	public boolean handlesMarks() {
		return true;
	}

	@Override
	public Collection<AudioBuffer> synthesize(XdmNode ssml, Voice voice,
	        TTSResource resource, List<Integer> marks, AudioBufferAllocator bufferAllocator)
		throws SynthesisException, InterruptedException, MemoryException {

		Map<String,Object> xsltParams = new HashMap<>(); {
			xsltParams.put("voice", voice.name);
			// add ending mark to ensure the complete SSML is processed
			xsltParams.put("ending-mark", "ending-mark");
		}
		try {
			Collection<AudioBuffer> result = speak(transformSsmlNodeToString(ssml, ssmlTransformer, xsltParams),
			             voice, resource, marks, bufferAllocator);
			// remove ending mark
			marks.subList(marks.size() - 1, marks.size()).clear();
			return result;
		} catch (IOException | SaxonApiException e) {
			throw new SynthesisException(e);
		}
	}

	public Collection<AudioBuffer> speak(String ssml, Voice voice, TTSResource resource,
	        List<Integer> marks, AudioBufferAllocator bufferAllocator) throws SynthesisException,
	        MemoryException {

		voice = mVoiceFormatConverter.get(voice.name.toLowerCase());

		ThreadResource tr = (ThreadResource) resource;
		int res = SAPILib.speak(tr.connection, voice.engine, voice.name, ssml);
		if (res != 0) {
			throw new SynthesisException("SAPI speak error number " + res + " with voice "
			        + voice);
		}

		int size = SAPILib.getStreamSize(tr.connection);

		AudioBuffer result = bufferAllocator.allocateBuffer(size);
		SAPILib.readStream(tr.connection, result.data, 0);

		long[] pos = SAPILib.getBookmarkPositions(tr.connection);

		float sampleRate = mAudioFormat.getSampleRate();
		int bytesPerSample = mAudioFormat.getSampleSizeInBits() / 8;
		for (int i = 0; i < pos.length; ++i) {
			int offset = (int) ((pos[i] * sampleRate * bytesPerSample) / 1000);
			marks.add(offset);
		}

		return Arrays.asList(result);
	}

	@Override
	public TTSResource allocateThreadResources() throws SynthesisException {
		long connection = SAPILib.openConnection();

		if (connection == 0) {
			throw new SynthesisException("could not open SAPI context.");
		}

		ThreadResource tr = new ThreadResource();
		tr.connection = connection;
		return tr;
	}

	@Override
	public Collection<Voice> getAvailableVoices() throws SynthesisException,
	        InterruptedException {
		if (mVoiceFormatConverter == null) {
			mVoiceFormatConverter = new HashMap<String, Voice>();
			String[] names = SAPILib.getVoiceNames();
			String[] vendors = SAPILib.getVoiceVendors();
			for (int i = 0; i < names.length; ++i) {
				mVoiceFormatConverter.put(names[i].toLowerCase(), new Voice(vendors[i],
				        names[i]));
			}
		}

		List<Voice> voices = new ArrayList<Voice>();
		for (String sapiVoice : mVoiceFormatConverter.keySet()) {
			voices.add(new Voice(getProvider().getName(), sapiVoice));
		}

		return voices;
	}

	@Override
	public AudioFormat getAudioOutputFormat() {
		return mAudioFormat;
	}

	@Override
	public int getOverallPriority() {
		return mOverallPriority;
	}

}
