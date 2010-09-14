package uk.co.fredemmott.jp.consumers;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import org.apache.thrift.transport.TTransportException;


public abstract class TextConsumer extends JobPoolConsumer <String> {
	private final static Charset utf8 = Charset.forName("UTF8");

	public TextConsumer(String hostname, int port, String pool) throws TTransportException {
		super(hostname, port, pool);
	}

	@Override
	public String deserialise(ByteBuffer message) {
		// UTF8 string serialisation.
		return utf8.decode(message).toString();
	}
	
}