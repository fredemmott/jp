package uk.co.fredemmott.jp.consumers;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import uk.co.fredemmott.jp.ClientFactory;
import uk.co.fredemmott.jp.Consumer;
import uk.co.fredemmott.jp.EmptyPool;
import uk.co.fredemmott.jp.Job;
import uk.co.fredemmott.jp.JobPool;
import uk.co.fredemmott.jp.NoSuchPool;

public abstract class JobPoolConsumer<T> implements Consumer<T> {
	private static final Logger logger = LoggerFactory.getLogger(JobPoolConsumer.class);
	private static final long POLL_INTERVAL = 1;
	private final JobPool.Iface client;
	private final String pool;
	private boolean running = true;
	
	public JobPoolConsumer(String hostname, int port, String pool) throws TTransportException {
		this.client = ClientFactory.getInstance().createClient(hostname, port);
		this.pool = pool;
	}

	public void run() {
		while (running) {
			// Poll for more jobs to process whilst we are running
			try {
				poll();
			} catch (NoSuchPool e) {
				// Log problem and return
				logger.error("No such pool: " + pool, e);
				return;
			} catch (TException e) {
				// Log problem and return
				logger.error("Error connecting to queue.", e);
				return;
			}
			
			// No more right now so wait
			try {
				Thread.sleep(POLL_INTERVAL);
			} catch (InterruptedException e1) {
				// Got interrupted!
				// Carry on..
			}
		}
	}
	
	private void poll() throws NoSuchPool, TException {
			// Loop until we have no jobs or we've been told to stop
			try {
				for (Job job=client.acquire(pool); job != null && running; job=client.acquire(pool)) {
					process(job);
				}
			} catch (EmptyPool e) {
				return;
			}
	}
	
	private void process(Job job) throws NoSuchPool, TException {
		// De-serialise message
		T message = deserialise(job.getMessage());
		
		// Purge from pool if completed
		if (consume(message)) {
			client.purge(pool, job.getId());
		}
	}
	
	@Override
	public void stop() {
		running = false;	
	}

}
