package uk.co.fredemmott.jp;

import org.apache.thrift.transport.TTransportException;

public class ClientFactory {

	private static ClientFactory instance = null;
	
	public static ClientFactory getInstance() {
		if (instance == null) {
			instance = new ClientFactory();
		}
		return instance;
	}
	
	public static void setInstance(ClientFactory clientFactory) {
		instance = clientFactory;
	}
	
	public JobPool.Iface createClient(String hostname, int port) throws TTransportException {
		return new RetryingClient(hostname, port);
	}
}
