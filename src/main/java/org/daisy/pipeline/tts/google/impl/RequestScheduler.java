package org.daisy.pipeline.tts.google.impl;

public interface RequestScheduler {

	/**
	 * 
	 * sleep the thread based on exponential backoff.
	 * 
	 */
	void sleep() throws InterruptedException;

}
