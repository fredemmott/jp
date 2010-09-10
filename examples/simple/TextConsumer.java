import org.apache.thrift.transport.TTransportException;

import uk.co.fredemmott.jp.Consumer;

/**
 * @author danharvey42@gmail.com
 *
 * TextConsumer is an example of extending the consumers in the library to implement
 * your own consumer methods.
 */
public class TextConsumer extends uk.co.fredemmott.jp.consumers.TextConsumer {

	public TextConsumer(String hostname, int port, String pool) throws TTransportException {
		super(hostname, port, pool);
	}

	@Override
	public boolean consume(String job) {
		System.out.println("Ive consumed: " + job);
		return true;
	}
	
	public static void main(String[] args) throws TTransportException {
		Consumer<String> myConsumer = new TextConsumer("localhost", 1234, "text");
		myConsumer.run();
	}
}