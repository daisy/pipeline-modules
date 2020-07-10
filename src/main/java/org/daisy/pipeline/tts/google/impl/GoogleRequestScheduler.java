package org.daisy.pipeline.tts.google.impl;

public class GoogleRequestScheduler implements RequestScheduler {
	
	private int waitingTime;
	private int random_number_milliseconds;
	private int n = 0;
	
	// maximum waiting time in millisecond
	private static final int MAXIMUM_BACKOFF = 64000;
	
	// https://cloud.google.com/storage/docs/exponential-backoff
	@Override
	public synchronized void sleep() throws InterruptedException {
		random_number_milliseconds = (int) (Math.random() * 1000);
		waitingTime = (int) Math.min(Math.pow(2, n) + random_number_milliseconds, MAXIMUM_BACKOFF);
		Thread.sleep(waitingTime);
		n++;
	}
	

}
