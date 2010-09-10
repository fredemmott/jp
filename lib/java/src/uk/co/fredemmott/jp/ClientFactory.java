package uk.co.fredemmott.jp;

import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransport;
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
		TTransport transport = new TSocket(hostname, port);
		TProtocol protocol = new TBinaryProtocol(transport);
		JobPool.Client client = new JobPool.Client(protocol);

		transport.open();
		return client;
	}
}
