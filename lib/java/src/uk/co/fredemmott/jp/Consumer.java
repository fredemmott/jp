package uk.co.fredemmott.jp;

import java.nio.ByteBuffer;

/**
 * Consumer interface....
 * 
 * @author danharvey42@gmail.com
 *
 * @param <T> type of the message from the jobs which the Consumer will consume.
 */
public interface Consumer <T> extends Runnable {

	/**
	 * consume will be called once for each job that the Consumer acquired from the pool. Once the
	 * work in completed boolean true or false should be returned to indicate if this job can 
	 * be removed from the pool or not.
	 * 
	 * @param message T of generic type to be processed for the job.
	 * @return boolean success of whether the job completed or not. This will determine
	 * if the job will be purged from the pool or not.
	 */
	public boolean consume(T message);
	
	/**
	 * @param message byte[] message to be de-serialised to T.
	 * @return generic type T which was de-serialised from the byte[] message.
	 */
	public T deserialise(ByteBuffer message);
	
	
	/**
	 * stop will gracefully stop the consumer processing job messages out of the pool.
	 */
	public void stop();
}