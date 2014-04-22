package org.daisy.pipeline.tts.synthesize;

public class TTSTimeout extends Thread {

	private Thread mJob;
	private int mSeconds;
	private boolean mOk;

	public TTSTimeout(int seconds) {
		mSeconds = seconds;
		mOk = true;
	}

	public void watch(Thread job) {
		mJob = job;
		start();
	}

	@Override
	public void run() {
		try {
			sleep(mSeconds * 1000);
		} catch (InterruptedException e) {
		}
		mOk = false;
		mJob.interrupt();
	}

	public boolean stillTime() {
		return mOk;
	}
}
