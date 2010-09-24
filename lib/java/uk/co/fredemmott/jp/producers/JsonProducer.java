package uk.co.fredemmott.jp.producers;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import org.apache.thrift.transport.TTransportException;
import org.json.JSONObject;

public class JsonProducer extends JobPoolProducer<JSONObject> {
	private final static Charset utf8 = Charset.forName("UTF8");

	public JsonProducer(String hostname, int port, String pool) throws TTransportException {
		super(hostname, port, pool);
	}
	
	@Override
	public ByteBuffer serialise(JSONObject message) {
		return utf8.encode(message.toString());
	}
}