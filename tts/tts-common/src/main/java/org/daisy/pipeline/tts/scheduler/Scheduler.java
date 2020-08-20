package org.daisy.pipeline.tts.scheduler;


/**
 * Scheduler interface to launch schedulable actions.
 * A schedulable action must be reschedule when a RecoverableError is raised.<br/>
 * 
 * An example of implementation is provided in the ExponentialBackoffScheduler
 * 
 * @author Louis Caille @ braillenet
 *
 * @param <Action> the schedulable action class to handle
 */
public interface Scheduler<Action extends Schedulable> {
	
	/**
	 * launch an action from the queue
	 * @param actionUuid unique id of the action to launch
	 * @throws InterruptedException if the scheduler thread is interrupted
	 * @throws FatalError if the action could not be executed or rescheduled after a RecoverableError
	 */
	public void launch(Action scheduled) throws InterruptedException, FatalError;

}
