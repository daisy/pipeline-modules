package org.daisy.pipeline.tts.synthesize;

public class TTSTimeout extends Thread {

	private Thread mJob;
	private int mSeconds;
	private boolean mOk;

	public TTSTimeout(Thread job, int seconds) {
		mJob = job;
		mSeconds = seconds;
		mOk = true;
	}

	@Override
	public void run() {
		try {
			sleep(mSeconds * 1000);
		} catch (InterruptedException e) {
			e.printStackTrace();
		}
		mOk = false;
		mJob.interrupt();
	}

	public boolean jobFinished() {
		return mOk;
	}
}
