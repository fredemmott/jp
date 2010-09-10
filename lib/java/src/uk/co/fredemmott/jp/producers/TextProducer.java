package uk.co.fredemmott.jp.producers;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import org.apache.thrift.transport.TTransportException;

public class TextProducer extends JobPoolProducer<String> {
	private final static Charset utf8 = Charset.forName("UTF8");

	public TextProducer(String hostname, int port, String pool) throws TTransportException {
		super(hostname, port, pool);
	}
	
	@Override
	public ByteBuffer serialise(String message) {
		return utf8.encode(message);
	}
}