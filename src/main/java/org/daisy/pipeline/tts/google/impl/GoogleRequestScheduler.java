package org.daisy.pipeline.tts.google.impl;

import java.time.Duration;
import java.time.LocalDateTime;

public class GoogleRequestScheduler implements RequestScheduler {
	
	private int waitingTime = 0;
	private int nbRequests = 0;
	private int nbChar = 0;
	private LocalDateTime timestamp;

	@Override
	public synchronized void addWaitingTime(int time) {
		waitingTime += time;
	}

	@Override
	public synchronized void sleep() throws InterruptedException {
		if (waitingTime > 0) {
			Thread.sleep(waitingTime);
			waitingTime = 0;
			nbRequests = 0;
			this.nbChar = 0;
		}
	}
	
	@Override
	public synchronized void addRequest(int nbChar, int time) throws InterruptedException {
		
		if (timestamp == null) {
			timestamp = LocalDateTime.now();
		}
		
		if ( Duration.between(timestamp, LocalDateTime.now()).getSeconds() > 60 ) {		
			nbRequests = 0;
			this.nbChar = 0;
			timestamp = LocalDateTime.now();	
		}
		
		nbRequests++;
		this.nbChar += nbChar;
		
		if ( Duration.between(timestamp, LocalDateTime.now()).getSeconds() <= 60 
				&& (nbRequests >= 300 || this.nbChar >= 15000) ) {	
			addWaitingTime(time);	
		}
	}
	
	@Override
	public synchronized void assertChar(int nbChar, int time) throws InterruptedException {
		if (this.nbChar + nbChar > 15000) {
			addWaitingTime(time);
			sleep();
		}
	}
	

}
