package org.daisy.pipeline.tts;

import net.sf.saxon.s9api.XdmNode;

public abstract class SingleAccessPointTTSService implements TTSService {

    private int nextJobIDstarted;
    private int lastJobIDfinished;
    private byte[] mResult;
    private int mResultSize;

    public SingleAccessPointTTSService() {
        nextJobIDstarted = 0;
        lastJobIDfinished = -1;
    }

    @Override
    public Object synthesize(XdmNode ssml, RawAudioBuffer audioBuffer,
            Object caller, Object memory) throws SynthesisException {

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
            }
        } catch (InterruptedException e) {
            throw new SynthesisException(e.getMessage(), e.getCause());
        }

        return null;
    }

    public void endJob(byte[] audioResult, int resultSize) {
        synchronized (this) {
            mResult = audioResult;
            mResultSize = resultSize;
            ++lastJobIDfinished;
            this.notifyAll();
        }
    }

    public abstract void startJob(XdmNode sssml);

}
