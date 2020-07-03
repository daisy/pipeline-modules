package org.daisy.pipeline.tts.google.impl;

import java.util.UUID;

public interface RequestScheduler {

	static class TRequest {
		
		public int nbChar;
		public int maxRequestsByMinute;
		public int maxCharByMinute;
		
		public TRequest(int nbChar, int maxRequestsByMinute, int maxCharByMinute) {
			this.nbChar = nbChar;
			this.maxRequestsByMinute = maxRequestsByMinute;
			this.maxCharByMinute = maxCharByMinute;
		}

	}

	UUID addRequest(TRequest req);

	TRequest getRequest(UUID requestID) throws InterruptedException;

}
