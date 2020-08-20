package org.daisy.pipeline.tts.scheduler;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

/**
 * Scheduler interface to delay requests when some quotas or errors are met.
 * An example of implementation is provided in the ExponentialBackoffScheduler
 * 
 * @author Louis Caille @ braillenet
 *
 * @param <Action> the schedulable action class to handle
 */
public abstract class Scheduler<Action extends Schedulable> {
	
	/**
	 * Queue of actions scheduled
	 */
	protected Map<UUID, Action> scheduledActions = new HashMap<>();
	
	/**
	 * Add a new action to the scheduler queue
	 * @param scheduled request to handle
	 * @return an unique id to poll and/or delay the request from the scheduler
	 */
	public UUID add(Action scheduled) {
		UUID actionUuid = UUID.randomUUID();
		while (scheduledActions.containsKey(actionUuid)) {
			actionUuid = UUID.randomUUID();
		}
		scheduledActions.put(actionUuid, scheduled);
		return actionUuid;
	}
	
	
	
	/**
	 * launch an action from the queue
	 * @param actionUuid unique id of the action to launch
	 * @throws InterruptedException if the scheduler thread is interrupted
	 * @throws FatalError if the action could not be executed or rescheduled after a RecoverableError
	 */
	public abstract void launch(UUID actionUuid) throws InterruptedException, FatalError;

}
