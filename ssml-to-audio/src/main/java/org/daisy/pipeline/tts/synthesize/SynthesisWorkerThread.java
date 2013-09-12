package org.daisy.pipeline.tts.synthesize;

import java.io.PrintWriter;
import java.io.StringWriter;
import java.util.LinkedList;
import java.util.List;

import net.sf.saxon.s9api.XdmNode;

import org.daisy.pipeline.audio.AudioEncoder;
import org.daisy.pipeline.tts.TTSService;
import org.daisy.pipeline.tts.TTSService.RawAudioBuffer;

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
	private final static SynthesizerJob EndSectionMarker = null;

	static private class SynthesizerJob {
		XdmNode ssml;
		TTSService synthesizer; // must be thread-safe!
	}

	// this list does not need to be thread-safe because the consuming step
	// (run() method) and the producing step (pushSSML method()) do not occur
	// simultaneously
	private LinkedList<SynthesizerJob> mSsmlPackets;

	public SynthesisWorkerThread() {
		mOutput = new byte[AUDIO_BUFFER_BYTES];
		mRawAudioBuffer = new RawAudioBuffer();
	}

	/**
	 * Initialize a worker with a given synthesizer and encoder.
	 * 
	 * @param soundfragments is the list of references to sound files (such as
	 *            mp3) produced by the combination of the synthesizer and the
	 *            encoder. Operations on this list must be thread-safe.
	 */
	public void init(AudioEncoder encoder,
	        List<SoundFragment> allSoundFragments, IPipelineLogger logger) {
		mEncoder = encoder;
		mOffsetInOutput = 0;
		mSsmlPackets = new LinkedList<SynthesizerJob>();
		mCurrentFragments = new LinkedList<SoundFragment>();
		mGlobalSoundFragments = allSoundFragments;
		mLogger = logger;
	}

	public void pushSSML(XdmNode ssml, TTSService synthesizer) {
		if (ssml == null) {
			mSsmlPackets.add(null);
		} else {
			SynthesizerJob sj = new SynthesizerJob();
			sj.ssml = ssml;
			sj.synthesizer = synthesizer;
			mSsmlPackets.add(sj);
		}
	}

	public void endSection() {
		mSsmlPackets.add(EndSectionMarker);
	}

	private void encodeAudio() {
		encodeAudio(mOutput, mOffsetInOutput);
	}

	private void encodeAudio(byte[] output, int size) {
		String soundFile = mEncoder.encode(output, size,
		        mLastUsedSynthesizer.getAudioOutputFormat(), this, null);

		for (SoundFragment sf : mCurrentFragments) {
			sf.soundFileURI = soundFile;
		}
		mGlobalSoundFragments.addAll(mCurrentFragments); // must be thread-safe

		// reset the state of the thread
		mOffsetInOutput = 0;
		mCurrentFragments.clear();
	}

	private double convertBytesToSecond(int bytes) {
		return (bytes / (mLastUsedSynthesizer.getAudioOutputFormat()
		        .getFrameRate() * mLastUsedSynthesizer.getAudioOutputFormat()
		        .getFrameSize()));
	}

	@Override
	public void run() {
		try {
			for (SynthesizerJob job : mSsmlPackets) {
				if (job == EndSectionMarker) {
					if (mOffsetInOutput > 0)
						encodeAudio();
					continue;
				}
				mLastUsedSynthesizer = job.synthesizer;

				if (mOffsetInOutput + MAX_ESTIMATED_SYNTHESIZED_BYTES > AUDIO_BUFFER_BYTES) {
					encodeAudio();
				}

				mRawAudioBuffer.output = mOutput;
				mRawAudioBuffer.offsetInOutput = mOffsetInOutput;
				Object memory = mLastUsedSynthesizer.synthesize(job.ssml,
				        mRawAudioBuffer, this, null);

				if (memory != null) {
					encodeAudio();
					// try again with more room for the data
					mLastUsedSynthesizer.synthesize(job.ssml, mRawAudioBuffer,
					        this, memory);
				} else if (mRawAudioBuffer.output != mOutput) {
					if ((mRawAudioBuffer.offsetInOutput + mOffsetInOutput) > mOutput.length) {
						// it has been externally allocated because it does not fit
						// in the current buffer
						if (mOffsetInOutput > 0)
							encodeAudio(); // flush
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
				SoundFragment sf = new SoundFragment();
				sf.id = job.ssml.getAttributeValue(Sentence_attr_id);
				sf.clipBegin = convertBytesToSecond(mOffsetInOutput);
				mOffsetInOutput = mRawAudioBuffer.offsetInOutput;
				sf.clipEnd = convertBytesToSecond(mOffsetInOutput);
				mCurrentFragments.add(sf);

				if (mRawAudioBuffer.output != mOutput) {
					// externally allocated case that does not fit in current buffer
					// => encode immediately
					encodeAudio(mRawAudioBuffer.output,
					        mRawAudioBuffer.offsetInOutput);
				}

			}
			if (mOffsetInOutput != 0)
				encodeAudio();
			mSsmlPackets = null;
		} catch (Exception e) {
			StringWriter sw = new StringWriter();
			e.printStackTrace(new PrintWriter(sw));
			mLogger.printInfo("error in synthesis thread: " + e + " "
			        + sw.toString());
		}
	}
}
