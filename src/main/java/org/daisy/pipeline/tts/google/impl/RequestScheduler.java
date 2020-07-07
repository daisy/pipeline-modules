package org.daisy.pipeline.tts.google.impl;

public interface RequestScheduler {
	
	/**
	 * 
	 * @param the waiting time that we want to add to the variable waitingTime.
	 * 
	 */
	void addWaitingTime(int time);
	
	/**
	 * 
	 * sleep the thread according to the waiting time.
	 * 
	 */
	void sleep() throws InterruptedException;
	
	/**
	 * 
	 * @param the number of characters in the sentence to be synthesized and the waiting time.
	 * 
	 */
	void addRequest(int nbChar, int waitingTime) throws InterruptedException;
	
	
	/**
	 * 
	 * @param the number of characters in the sentence to be synthesized and the waiting time.
	 * 
	 * checks if the quota on characters will not be exceeded
	 * 
	 */
	void assertChar(int nbChar, int waitingTime) throws InterruptedException;

}
