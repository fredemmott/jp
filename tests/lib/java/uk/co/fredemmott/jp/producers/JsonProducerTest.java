package uk.co.fredemmott.jp.producers;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.verify;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;

import org.apache.thrift.transport.TTransportException;
import org.json.JSONException;
import org.json.JSONObject;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.Mock;
import org.mockito.runners.MockitoJUnitRunner;

import uk.co.fredemmott.jp.ClientFactory;
import uk.co.fredemmott.jp.Producer;

@RunWith(MockitoJUnitRunner.class)
public class JsonProducerTest {
	private static final String TEST_MESSAGE = "{\"message\":\"test message\"}";

	@Mock private ClientFactory mockFactory;
	
	protected static final String HOSTNAME = "localhost";
	protected static final int PORT = 1234;
	private static final String POOL = "test_pool";
	
	private final static Charset utf8 = Charset.forName("UTF8");
	
	@Before
	public void setUp() throws Exception {
		ClientFactory.setInstance(mockFactory);
	}
	
	@After 
	public void tearDown() {
		ClientFactory.setInstance(null);
	}
	
	@Test
	public void testTextProducer() throws TTransportException {
		@SuppressWarnings("unused")
		Producer<JSONObject> consumer = new JsonProducer(HOSTNAME, PORT, POOL);
		
		verify(mockFactory).createClient(HOSTNAME, PORT);
	}

	@Test
	public void testSerialise() throws TTransportException, JSONException {
		Producer<JSONObject> consumer = new JsonProducer(HOSTNAME, PORT, POOL);
		
		ByteBuffer bytes = consumer.serialise(new JSONObject(TEST_MESSAGE));
		
		assertEquals(utf8.encode(TEST_MESSAGE), bytes);
	}

}
