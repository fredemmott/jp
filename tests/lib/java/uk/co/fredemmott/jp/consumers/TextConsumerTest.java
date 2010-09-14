package uk.co.fredemmott.jp.consumers;

import static org.junit.Assert.assertEquals;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

import java.nio.ByteBuffer;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransportException;
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
public class TextConsumerTest {
	private static final String TEST_STRING = "Test String";
	private final static Charset utf8 = Charset.forName("UTF8");
	private static final String ID_ONE = "id_one";
	private static final String ID_TWO = "id_two";
	
	private static final String MESSAGE_ONE = "string_one";
	private static final String MESSAGE_TWO = "string_two";
	
	protected static final String HOSTNAME = "localhost";
	protected static final int PORT = 1234;
	private static final String POOL = "test_pool";
	
	@Mock private JobPool.Iface mockClient;
	@Mock private ClientFactory mockFactory;
	
	/**
	 * LoggingTextConsumer will log message it consumer and count them.
	 *
	 */
	private static class LoggingTextConsumer extends TextConsumer {
		int count = 0;
		List<String> messages = new ArrayList<String>();
		
		public LoggingTextConsumer(String hostname, int port, String pool) throws TTransportException {
			super(hostname, port, pool);
		}

		@Override
		public boolean consume(String message) {
			count++;
			messages.add(message);
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
		Consumer<String> consumer = new LoggingTextConsumer(HOSTNAME, PORT, POOL);
		
		verify(mockFactory).createClient(HOSTNAME, PORT);
	}
	
	@Test
	public void testDeserialise() throws TTransportException {
		Consumer<String> consumer = new LoggingTextConsumer(HOSTNAME, PORT, POOL);
		
		ByteBuffer bytes = utf8.encode(TEST_STRING);
		
		String test = consumer.deserialise(bytes);
		
		assertEquals(TEST_STRING, test);
	}

	@Test
	public void testRun_OneItem() throws NoSuchPool, EmptyPool, TException, InterruptedException {
		
		when(mockFactory.createClient(HOSTNAME, PORT)).thenReturn(mockClient);
		
		// Set message on the queue
		when(mockClient.acquire(POOL))
			.thenReturn(new Job(utf8.encode(MESSAGE_ONE), utf8.encode(ID_ONE)))
			.thenReturn(new Job(utf8.encode(MESSAGE_TWO), utf8.encode(ID_TWO)))
			.thenThrow(new EmptyPool());
		
		LoggingTextConsumer consumer = new LoggingTextConsumer(HOSTNAME, PORT, POOL);
		
		// Run as background thread then tell to stop after processing documents.
		Thread t = new Thread(consumer);
		t.start();
		Thread.sleep(2); // Could in case this if it starts to be a problem.
		consumer.stop();
		
		// Check it gets messages
		assertEquals(2, consumer.count);
		assertEquals(Arrays.asList(MESSAGE_ONE, MESSAGE_TWO), consumer.messages);
				
		verify(mockClient).purge(POOL, utf8.encode(ID_ONE));
		verify(mockClient).purge(POOL, utf8.encode(ID_TWO));
	}
}
