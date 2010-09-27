package uk.co.fredemmott.jp;

import java.nio.ByteBuffer;

import org.apache.thrift.TException;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
import org.apache.thrift.transport.TTransportException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author danharvey42@gmail.com
 * 
 * RetryingClient encapsulates the thrift client and adds code to retry calls and connections a give number of times.
 *
 */
public class RetryingClient implements JobPool.Iface {

	private final Logger logger = LoggerFactory.getLogger(RetryingClient.class);
	
	private static final int MAX_CONNECT_ATTEMPTS = 5;
	private static final int MAX_FAIL_ATTEMPTS = 2;

	private static final double RETRY_WAIT_GROWTH_CONSTANT = 0.5;
	private static final double RETRY_WAIT_SCALING_CONSTANT = 0.4;
	
	private final JobPool.Iface client;
	private final TTransport transport;
	
	public RetryingClient(String hostname, int port) {
		transport = new TSocket(hostname, port);
		TProtocol protocol = new TBinaryProtocol(transport);
		client = new JobPool.Client(protocol);

		connectTransport();
	}
	
	/**
	 * conntectTransport will try to connect the transport for the thrift service
	 * with multiple attempts and time based backing off. It will try to connect
	 * MAX_CONNECT_ATTEMPTS times with an increasing gap between each.
	 *  
	 * @return true is the connection succeeds, false if not. 
	 */
	private boolean connectTransport() {
		logger.info("Trying to connect Thrift transport");
		
		// Make sure it's closed first.
		transport.close();
		
		// Try and connect until we've run out of attempts
		int attempt = 0;
		while (attempt < MAX_CONNECT_ATTEMPTS) {
			// Wait before the next attempt
			try {
				this.wait(retryWait(attempt));
			} catch (InterruptedException e1) {
				// Been woke up, carry on!
			}
				
			// Is transport is already connected?
			if (transport.isOpen()) {
				logger.info("Thrift transport is already connected");
				return true;
			}
			// Not connected to try and connect
			attempt++;
			try {
				transport.open();
			} catch (TTransportException e) {
				// Failed to open, log and continue.
				logger.error("There was an error trying to connect the thrift transport", e);
				continue;
			}
			
			// Connected without an error.
			logger.info("Successfuly connected Thrift transport");
			return true;
		}
		
		// Ran out of attempts.
		logger.error("Failed to connect the thrift transport after {} attempts", MAX_CONNECT_ATTEMPTS);
		return false;
	}
	
	/**
	 * retryWait returns the time to wait for a given attempt.
	 * Currently this is implemented using an exponential growth function
	 * with a scaling and growth constant to control the rate the time
	 * changes.
	 * 
	 * @param attempt integer of the number of the attempt made
	 * @return time to wait as a long in milliseconds
	 */
	protected static long retryWait(int attempt) {
		return (long)((RETRY_WAIT_SCALING_CONSTANT*Math.exp(attempt*RETRY_WAIT_GROWTH_CONSTANT) - RETRY_WAIT_SCALING_CONSTANT)*1000);
	}

	@Override
	public Job acquire(String pool) throws NoSuchPool, EmptyPool, TException {
		int attempt = 0;
		while (true) {
			attempt++;
			try {
				return client.acquire(pool);
			} catch (TException e) {
				// Error running the request, try reconnecting
				if (attempt > MAX_FAIL_ATTEMPTS){
					// Too many attempts
					logger.error("Too many attempts, throwing exception");
				} else { if (connectTransport()) {
					continue;
				} else {
					// Error reconnecting
					logger.error("Could not reconnect thrift transport after exception");
				}
				
				// Could not re-connect or too many attempts to throw the exception;
				throw e;
				}
			}
		}
	}

	@Override
	public void add(String pool, ByteBuffer message) throws NoSuchPool, TException {
		int attempt = 0;
		while (true) {
			attempt++;
			try {
				client.add(pool, message);
			} catch (TException e) {
				// Error running the request, try reconnecting
				if (attempt > MAX_FAIL_ATTEMPTS){
					// Too many attempts
					logger.error("Too many attempts, throwing exception");
				} else { if (connectTransport()) {
					continue;
				} else {
					// Error reconnecting
					logger.error("Could not reconnect thrift transport after exception");
				}
				
				// Could not re-connect or too many attempts to throw the exception;
				throw e;
				}
			}
		}
	}

	@Override
	public void purge(String pool, ByteBuffer id) throws NoSuchPool, TException {
		int attempt = 0;
		while (true) {
			attempt++;
			try {
				client.purge(pool, id);
			} catch (TException e) {
				// Error running the request, try reconnecting
				if (attempt > MAX_FAIL_ATTEMPTS){
					// Too many attempts
					logger.error("Too many attempts, throwing exception");
				} else { if (connectTransport()) {
					continue;
				} else {
					// Error reconnecting
					logger.error("Could not reconnect thrift transport after exception");
				}
				
				// Could not re-connect or too many attempts to throw the exception;
				throw e;
				}
			}
		}
	}

}
