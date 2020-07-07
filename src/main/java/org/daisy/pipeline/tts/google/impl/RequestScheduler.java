package org.daisy.pipeline.tts.google.impl;

public interface RequestScheduler {
	
	void addWaitingTime(int time);
	
	void sleep() throws InterruptedException;

	void addRequest(int nbChar, int waitingTime) throws InterruptedException;
	
	void assertChar(int nbChar, int waitingTime) throws InterruptedException;

}
