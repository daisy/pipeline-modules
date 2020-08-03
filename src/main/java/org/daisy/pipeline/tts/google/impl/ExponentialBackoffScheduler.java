package org.daisy.pipeline.tts.google.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class ExponentialBackoffScheduler<RequestType> implements RequestScheduler<RequestType> {
	
	private int n = 0;
	
	private Map<UUID, RequestType> requests = new HashMap<>();
	private Map<UUID, Long> delays = new HashMap<>();
	
	// maximum waiting time in millisecond
	private static final int MAXIMUM_BACKOFF = 64000;
	
	// https://cloud.google.com/storage/docs/exponential-backoff
	// https://docs.aws.amazon.com/general/latest/gr/api-retries.html
	private synchronized long waitingTime() throws InterruptedException {
		long random_number_milliseconds = (long) (Math.random() * 1000);
		long waitingTime = (long) Math.min(Math.pow(2, n) * 100L + random_number_milliseconds, MAXIMUM_BACKOFF);
		n++;
		return waitingTime;
	}

	@Override
	public synchronized UUID add(RequestType request) {
		UUID requestUuid = UUID.randomUUID();
		while (requests.containsKey(requestUuid)) {
			requestUuid = UUID.randomUUID();
		}
		requests.put(requestUuid, request);
		return requestUuid;
	}

	@Override
	public synchronized void delay(UUID requestUuid) throws InterruptedException {
		long delay = waitingTime();
		delays.put(requestUuid, delay);
	}

	@Override
	public synchronized RequestType poll(UUID requestUuid) throws InterruptedException {
		if (delays.containsKey(requestUuid)) {
			Thread.sleep(delays.remove(requestUuid));
		}
		return requests.remove(requestUuid);
	}

}
