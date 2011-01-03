package uk.co.fredemmott.jp.consumers;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import org.apache.thrift.transport.TTransportException;
import org.json.JSONException;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * @author danharvey42@gmail.com
 *
 */

public abstract class JsonConsumer extends JobPoolConsumer <JSONObject> {
	private final static Charset utf8 = Charset.forName("UTF8");
	private final Logger logger = LoggerFactory.getLogger(JsonConsumer.class);

	public JsonConsumer(String hostname, int port, String pool) throws TTransportException {
		super(hostname, port, pool);
	}

	@Override
	public JSONObject deserialise(ByteBuffer message) {
		// UTF8 string serialisation.
		
		String jsonString = utf8.decode(message).toString();
		
		JSONObject json = null;
		
		try {
			json = new JSONObject(jsonString);
		} catch (JSONException e) {
			logger.error("Could not deserialise json message: " + jsonString, e);
		}
		
		return json;
	}
	
}