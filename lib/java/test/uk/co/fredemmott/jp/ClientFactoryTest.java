package uk.co.fredemmott.jp;

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class ClientFactoryTest {

	@Before
	public void setUp() throws Exception {
	}

	@Test
	public void testGetInstance() {
		ClientFactory instanceOne = ClientFactory.getInstance();
		ClientFactory instanceTwo = ClientFactory.getInstance();
		
		assertSame(instanceOne, instanceTwo);
	}

	@Test
	public void testSetInstance() {
		ClientFactory instance = new ClientFactory();
		ClientFactory.setInstance(instance);
		
		assertSame(instance, ClientFactory.getInstance());
	}
}
