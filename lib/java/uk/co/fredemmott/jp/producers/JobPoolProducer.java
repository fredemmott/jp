package uk.co.fredemmott.jp.producers;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;

import uk.co.fredemmott.jp.ClientFactory;
import uk.co.fredemmott.jp.JobPool;
import uk.co.fredemmott.jp.NoSuchPool;
import uk.co.fredemmott.jp.PoolException;
import uk.co.fredemmott.jp.Producer;

public abstract class JobPoolProducer<T> implements Producer<T> {
	private JobPool.Iface client;
	private String pool;
	
	public JobPoolProducer(String hostname, int port, String pool) throws TTransportException {
		this.pool = pool;
		client = ClientFactory.getInstance().createClient(hostname, port);
	}
	
	@Override
	public void add(T message) throws PoolException {
		try {
			client.add(pool, serialise(message));
		} catch (TException e) {
			// Connection error with thrift, throw exception that we can't add the item.
			throw new PoolException("Unable to add message to pool due to a transport error", e);
		} catch (NoSuchPool e) {
			// The pool does not exist so throw an exception because of this.
			throw new PoolException("Unable to add message to the pool as the pool does not exist", e);
		}
	}
}