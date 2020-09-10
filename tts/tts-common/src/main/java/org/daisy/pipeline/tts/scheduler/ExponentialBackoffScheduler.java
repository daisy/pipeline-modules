package org.daisy.pipeline.tts.scheduler.impl;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

import org.daisy.pipeline.tts.scheduler.FatalError;
import org.daisy.pipeline.tts.scheduler.RecoverableError;
import org.daisy.pipeline.tts.scheduler.Schedulable;
import org.daisy.pipeline.tts.scheduler.Scheduler;


/**
 * Scheduler that increase the delay between actions launch,
 * using a number of seconds equals to apower of 2 times retries
 * and a random number of milliseconds.
 * <br/>
 * These scheduler implementation is based on 
 * <a href="https://cloud.google.com/storage/docs/exponential-backoff">Google</a> 
 * and <a href="https://docs.aws.amazon.com/general/latest/gr/api-retries.html">Amazon</a> 
 * recommendations.
 * 
 * @author Louis Caille @ braillenet.org
 *
 * @param <RequestType> class of request objects to handle
 */
public class ExponentialBackoffScheduler<RequestType extends Schedulable> extends Scheduler<RequestType> {
	
	
	/**
	 *  maximum waiting time in millisecond
	 */
	private static final int MAXIMUM_BACKOFF = 64000;
	
	/**
	 * Waiting time computed following <a href="https://cloud.google.com/storage/docs/exponential-backoff">Google</a> 
 	 * and <a href="https://docs.aws.amazon.com/general/latest/gr/api-retries.html">Amazon</a> 
 	 * recommendations
	 * @return the waiting time in milliseconds
	 */
	private long waitingTime(int attemptCounter){
		long random_number_milliseconds = (long) (Math.random() * 1000);
		long waitingTime = (long) Math.min(Math.pow(2, attemptCounter) * 1000L + random_number_milliseconds, MAXIMUM_BACKOFF);
		return waitingTime;
	}


	/**
	 * When a recoverable error is thrown, the scheduler keep the action in its queue 
	 * and delays all launches by sleeping the thread while in locked state
	 */
	@Override
	public void launch(UUID actionUuid) throws InterruptedException, FatalError {
		int attempt = 0;
		while(this.scheduledActions.containsKey(actionUuid)) {
			try {
				this.scheduledActions.get(actionUuid).launch();
				this.scheduledActions.remove(actionUuid);
			} catch (RecoverableError e){
				System.out.println("Rescheduling " + actionUuid.toString() + "due to recoverable error (attempt " + (attempt+1) + ") : " + e.getMessage());
				Thread.sleep(waitingTime(attempt));
				attempt++;
			}
		}
	}

}
