package uk.co.fredemmott.jp;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class RetryingClientTest {

	@Before
	public void setUp() throws Exception {
	}

	@Test
	public void testRetryWait() {
		assertEquals(0, RetryingClient.retryWait(0));
		
		long second = RetryingClient.retryWait(1);
		long third = RetryingClient.retryWait(2);
		assertTrue(third > second);
		
		for (int i=0; i<10; i++) {
			System.out.println(RetryingClient.retryWait(i));
		}
	}

}
