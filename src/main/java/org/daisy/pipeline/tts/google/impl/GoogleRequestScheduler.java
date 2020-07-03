package org.daisy.pipeline.tts.google.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class GoogleRequestScheduler implements RequestScheduler {
	
	private int mNbRequests = 0;
	private int mNbChar = 0;
	
	private Map<UUID, TRequest> mRequests = new HashMap<>();
	

	@Override
	public synchronized UUID addRequest(TRequest req) {
		UUID uuid = UUID.randomUUID();
		while (mRequests.containsKey(uuid)) {
			uuid = UUID.randomUUID();
		}
		mRequests.put(uuid, req);
		return uuid;
	}

	@Override
	public synchronized TRequest getRequest(UUID requestID) throws InterruptedException {
		TRequest req = mRequests.get(requestID);
		if (mNbRequests >= req.maxRequestsByMinute || mNbChar + req.nbChar > req.maxCharByMinute) {
			Thread.sleep(60000);
			mNbRequests = 0;
			mNbChar = 0;
		}
		mNbRequests++;
		mNbChar += req.nbChar;
		mRequests.remove(requestID);
		
		return req;
	}

}
