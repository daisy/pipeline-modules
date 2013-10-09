package org.daisy.pipeline.tts;

import java.util.List;
import java.util.Map.Entry;

import net.sf.saxon.s9api.XdmNode;

public abstract class SingleAccessPointTTSService implements TTSService {

	private int nextJobIDstarted;
	private int lastJobIDfinished;
	private byte[] mResult;
	private int mResultSize;
	private List<Entry<String, Double>> mResultMarks;

	public SingleAccessPointTTSService() {
		nextJobIDstarted = 0;
		lastJobIDfinished = -1;
	}

	@Override
	public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
	        Object caller, Object memory, List<Entry<String, Double>> marks)
	        throws SynthesisException {

		int myID;
		synchronized (this) {
			myID = nextJobIDstarted++;
			startJob(ssml);
		}

		try {
			synchronized (this) {
				while (lastJobIDfinished != myID) {
					this.wait();
				}
				// here the job is finished
				audioBuffer.offsetInOutput = mResultSize;
				audioBuffer.output = mResult;
				marks.addAll(mResultMarks);
			}
		} catch (InterruptedException e) {
			throw new SynthesisException(e.getMessage(), e.getCause());
		}

		return null;
	}

	public void endJob(byte[] audioResult, int resultSize,
	        List<Entry<String, Double>> marks) {
		synchronized (this) {
			mResult = audioResult;
			mResultSize = resultSize;
			mResultMarks = marks;
			++lastJobIDfinished;
			this.notifyAll();
		}
	}

	public abstract void startJob(XdmNode ssml);

}
