package org.daisy.pipeline.tts.google.impl;

import java.time.Duration;
import java.time.LocalDateTime;

public class GoogleRequestScheduler implements RequestScheduler {
	
	private int waitingTime = 0;
	private int nbRequests = 0;
	private int nbChar = 0;
	private LocalDateTime timestamp;

	// 65000ms is used as a wait time with the Google API
	// quotas are 300 requests per minute or 15000 characters
	
	@Override
	public synchronized void addWaitingTime(int time) {
		waitingTime += time;
	}

	@Override
	public synchronized void sleep() throws InterruptedException {
		if (waitingTime > 0) {
			Thread.sleep(waitingTime);
			// after a sleep everything is reset to zero
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
		
		// if more than a minute has passed since the last request then the counters are set to 0
		if ( Duration.between(timestamp, LocalDateTime.now()).getSeconds() > 60 ) {		
			nbRequests = 0;
			this.nbChar = 0;
			timestamp = LocalDateTime.now();	
		}
		
		nbRequests++;
		this.nbChar += nbChar;
		
		// if quotas are exceeded, waiting time is added
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
