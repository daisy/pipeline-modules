package org.daisy.pipeline.tts.synthesize;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentLinkedQueue;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioEncoder;
import org.daisy.pipeline.tts.TTSService;
import org.daisy.pipeline.tts.TTSService.RawAudioBuffer;
import org.daisy.pipeline.tts.TTSService.SynthesisException;
import org.daisy.pipeline.tts.TTSService.Voice;
import org.daisy.pipeline.tts.synthesize.SynthesisWorkerPool.Speakable;
import org.daisy.pipeline.tts.synthesize.SynthesisWorkerPool.UndispatchableSection;

/**
 * The SynthesisWorkerThread is meant to be used by a SynthesisWorkerPool. It
 * works as follow: when it receives a new piece of SSML, it calls the
 * synthesizer to transform it to raw audio data. The data is added to the
 * thread's internal audio buffer and when the buffer is about to be full, the
 * threads call the encoder to transform the buffer into a compressed audio
 * file.
 */
public class SynthesisWorkerThread extends Thread implements
        FormatSpecifications {

	// 20 seconds with 24kHz 16 bits audio
	private static final int MAX_ESTIMATED_SYNTHESIZED_BYTES = 24000 * 2 * 20;

	// 2 minutes, i.e. ~6MBytes
	private static final int AUDIO_BUFFER_BYTES = 24000 * 2 * 60 * 2;

	private AudioEncoder mEncoder; // must be thread-safe!
	private byte[] mOutput;
	private int mOffsetInOutput;
	private List<SoundFragment> mGlobalSoundFragments; // must be thread-safe!
	private List<SoundFragment> mCurrentFragments;
	private IPipelineLogger mLogger;
	private TTSService mLastUsedSynthesizer; // must be thread-safe!
	private RawAudioBuffer mRawAudioBuffer;
	private ConcurrentLinkedQueue<UndispatchableSection> mSectionsQueue;
	private Map<TTSService, Object> mResources;
	private int mCurrentDocPosition;
	private int mSectionFiles;

	public SynthesisWorkerThread() {
		mOutput = new byte[AUDIO_BUFFER_BYTES];
		mRawAudioBuffer = new RawAudioBuffer();
		mResources = new HashMap<TTSService, Object>();
	}

	public void init(AudioEncoder encoder, IPipelineLogger logger,
	        List<SoundFragment> allSoundFragments,
	        ConcurrentLinkedQueue<UndispatchableSection> sectionQueue) {
		mEncoder = encoder;
		mOffsetInOutput = 0;
		mCurrentFragments = new LinkedList<SoundFragment>();
		mGlobalSoundFragments = allSoundFragments;
		mLogger = logger;
		mSectionsQueue = sectionQueue;
	}

	private void encodeAudio() {
		encodeAudio(mOutput, mOffsetInOutput);
	}

	private void encodeAudio(byte[] output, int size) {
		String preferredFileName = String.format("section%04d_%02d",
		        mCurrentDocPosition, mSectionFiles);

		String soundFile = mEncoder.encode(output, size,
		        mLastUsedSynthesizer.getAudioOutputFormat(), this,
		        preferredFileName);

		for (SoundFragment sf : mCurrentFragments) {
			sf.soundFileURI = soundFile;
		}
		mGlobalSoundFragments.addAll(mCurrentFragments); // must be thread-safe

		// reset the state of the thread
		mOffsetInOutput = 0;
		mCurrentFragments.clear();
		++mSectionFiles;
	}

	private double convertBytesToSecond(int bytes) {
		return (bytes / (mLastUsedSynthesizer.getAudioOutputFormat()
		        .getFrameRate() * mLastUsedSynthesizer.getAudioOutputFormat()
		        .getFrameSize()));
	}

	public void allocateResourcesFor(TTSService s) throws SynthesisException {
		mResources.put(s, s.allocateThreadResources());
	}

	public void releaseResources() throws SynthesisException {
		for (Map.Entry<TTSService, Object> resource : mResources.entrySet()) {
			resource.getKey().releaseThreadResources(resource.getValue());
		}
	}

	private void processOneSentence(XdmNode sentence, Voice voice)
	        throws SynthesisException {
		if (mOffsetInOutput + MAX_ESTIMATED_SYNTHESIZED_BYTES > AUDIO_BUFFER_BYTES) {
			encodeAudio();
		}
		Object resource = mResources.get(mLastUsedSynthesizer);
		List<Map.Entry<String, Double>> marks = new ArrayList<Map.Entry<String, Double>>();
		mRawAudioBuffer.output = mOutput;
		mRawAudioBuffer.offsetInOutput = mOffsetInOutput;
		Object memory = mLastUsedSynthesizer.synthesize(sentence, voice,
		        mRawAudioBuffer, resource, null, marks);

		if (memory != null) {
			encodeAudio();
			// try again with the room freed after encoding
			marks.clear();
			mLastUsedSynthesizer.synthesize(sentence, voice, mRawAudioBuffer,
			        resource, memory, marks);
		} else if (mRawAudioBuffer.output != mOutput) {
			if ((mRawAudioBuffer.offsetInOutput + mOffsetInOutput) > mOutput.length) {
				// it has been externally allocated because it does not fit
				// in the current buffer
				if (mOffsetInOutput > 0)
					encodeAudio();
			} else {
				// this makes sense when TTS engine's policy is to always use its own buffers,
				// even when it could fit in the current buffer
				System.arraycopy(mRawAudioBuffer.output, 0, mOutput,
				        mOffsetInOutput, mRawAudioBuffer.offsetInOutput);
				mRawAudioBuffer.output = mOutput;
				mRawAudioBuffer.offsetInOutput += mOffsetInOutput;
			}
		}

		// keep track of where the sound begins and where it ends in the audio buffer
		if (marks.size() == 0) {
			SoundFragment sf = new SoundFragment();
			sf.id = sentence.getAttributeValue(Sentence_attr_id);
			sf.clipBegin = convertBytesToSecond(mOffsetInOutput);
			mOffsetInOutput = mRawAudioBuffer.offsetInOutput;
			sf.clipEnd = convertBytesToSecond(mOffsetInOutput);
			mCurrentFragments.add(sf);
		} else {
			double begin = convertBytesToSecond(mOffsetInOutput);
			mOffsetInOutput = mRawAudioBuffer.offsetInOutput;
			double end = convertBytesToSecond(mOffsetInOutput);

			Map<String, Double> starts = new HashMap<String, Double>();
			Map<String, Double> ends = new HashMap<String, Double>();
			Set<String> all = new HashSet<String>();

			for (Map.Entry<String, Double> e : marks) {
				String[] mark = e.getKey().split(
				        FormatSpecifications.MarkDelimiter, -1);
				if (!mark[0].isEmpty()) {
					ends.put(mark[0], e.getValue());
					all.add(mark[0]);
				}
				if (!mark[1].isEmpty()) {
					starts.put(mark[1], e.getValue());
					all.add(mark[1]);
				}
			}
			for (String id : all) {
				SoundFragment sf = new SoundFragment();
				sf.id = id;
				if (starts.containsKey(id))
					sf.clipBegin = begin + starts.get(id);
				else
					sf.clipBegin = begin;
				if (ends.containsKey(id))
					sf.clipEnd = begin + ends.get(id);
				else
					sf.clipEnd = end;
				mCurrentFragments.add(sf);
			}
		}

		if (mRawAudioBuffer.output != mOutput) {
			// externally allocated case that does not fit in current buffer
			// => encode immediately
			encodeAudio(mRawAudioBuffer.output, mRawAudioBuffer.offsetInOutput);
		}
	}

	@Override
	public void run() {
		while (true) {
			UndispatchableSection section = mSectionsQueue.poll();
			if (section == null) {
				break;
			}
			try {
				mCurrentDocPosition = section.documentPosition;
				mSectionFiles = 0;
				mLastUsedSynthesizer = section.synthesizer;
				for (Speakable speakable : section.speakables) {
					processOneSentence(speakable.sentence, speakable.voice);
				}
				if (mOffsetInOutput > 0)
					encodeAudio();
			} catch (Exception e) {
				StringWriter sw = new StringWriter();
				e.printStackTrace(new PrintWriter(sw));
				mLogger.printInfo("error in synthesis thread: "
				        + e.getMessage() + " : " + sw.toString());
			}
		}
	}
}
