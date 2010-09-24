package uk.co.fredemmott.jp.consumers;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import org.apache.thrift.TException;
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
import uk.co.fredemmott.jp.Consumer;
import uk.co.fredemmott.jp.EmptyPool;
import uk.co.fredemmott.jp.Job;
import uk.co.fredemmott.jp.JobPool;
import uk.co.fredemmott.jp.NoSuchPool;

@RunWith(MockitoJUnitRunner.class)
public class JsonConsumerTest {
	private static final String TEST_STRING = "{\"message\":\"Test String\"}";
	private final static Charset utf8 = Charset.forName("UTF8");
	private static final String ID_ONE = "id_one";
	private static final String ID_TWO = "id_two";
	
	private static final String MESSAGE_ONE = "{\"message\":\"String 1\"}";
	private static final String MESSAGE_TWO = "{\"message\":\"String 2\"}";
	
	protected static final String HOSTNAME = "localhost";
	protected static final int PORT = 1234;
	private static final String POOL = "test_pool";
	
	@Mock private JobPool.Iface mockClient;
	@Mock private ClientFactory mockFactory;
	
	/**
	 * LoggingTextConsumer will log message it consumer and count them.
	 *
	 */
	private static class LoggingJsonConsumer extends JsonConsumer {
		int count = 0;
		List<JSONObject> messages = new ArrayList<JSONObject>();
		
		public LoggingJsonConsumer(String hostname, int port, String pool) throws TTransportException {
			super(hostname, port, pool);
		}

		@Override
		public boolean consume(JSONObject json) {
			count++;
			messages.add(json);
			return true;
		}
	}
	
	@Before
	public void setUp() throws Exception {
		ClientFactory.setInstance(mockFactory);
	}
	
	@After 
	public void tearDown() {
		ClientFactory.setInstance(null);
	}
	
	@Test
	public void testTextConsumer() throws TTransportException {
		@SuppressWarnings("unused")
		Consumer<JSONObject> consumer = new LoggingJsonConsumer(HOSTNAME, PORT, POOL);
		
		verify(mockFactory).createClient(HOSTNAME, PORT);
	}
	
	@Test
	public void testDeserialise() throws TTransportException, JSONException {
		Consumer<JSONObject> consumer = new LoggingJsonConsumer(HOSTNAME, PORT, POOL);
		
		ByteBuffer bytes = utf8.encode(TEST_STRING);
		
		JSONObject test = consumer.deserialise(bytes);
		
		assertEquals(new JSONObject(TEST_STRING).toString(), test.toString());
	}

	@Test
	public void testRun_OneItem() throws NoSuchPool, EmptyPool, TException, InterruptedException, JSONException {
		
		when(mockFactory.createClient(HOSTNAME, PORT)).thenReturn(mockClient);
		
		// Set message on the queue
		when(mockClient.acquire(POOL))
			.thenReturn(new Job(utf8.encode(MESSAGE_ONE), utf8.encode(ID_ONE)))
			.thenReturn(new Job(utf8.encode(MESSAGE_TWO), utf8.encode(ID_TWO)))
			.thenThrow(new EmptyPool());
		
		LoggingJsonConsumer consumer = new LoggingJsonConsumer(HOSTNAME, PORT, POOL);
		
		// Run as background thread then tell to stop after processing documents.
		Thread t = new Thread(consumer);
		t.start();
		Thread.sleep(10); // Could in case this if it starts to be a problem.
		consumer.stop();
		
		// Check it gets messages
		assertEquals(2, consumer.count);
		assertEquals(consumer.messages.get(0).toString(), MESSAGE_ONE);
		assertEquals(consumer.messages.get(1).toString(), MESSAGE_TWO);
				
		verify(mockClient).purge(POOL, utf8.encode(ID_ONE));
		verify(mockClient).purge(POOL, utf8.encode(ID_TWO));
	}
}
