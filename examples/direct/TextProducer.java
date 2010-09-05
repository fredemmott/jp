import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransport;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransportException;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import uk.co.fredemmott.jp.*;

public class TextProducer
{
	public static void main(String[] args)
	{
		try
		{
			TTransport transport = new TSocket("localhost", 9090);
			TProtocol protocol = new TBinaryProtocol(transport);
			JobPool.Client client = new JobPool.Client(protocol);

			transport.open();

			System.out.println("Adding a bean...");
			client.add("text", "bean".getBytes("UTF-8"));
			System.out.println("Added a bean.");
		}
		catch (java.io.UnsupportedEncodingException e)
		{
			System.out.println("UTF-8 encoding not supported, couldn't add item.");
		}
		catch (NoSuchPool e)
		{
			System.out.println("Pool 'text' does not exist, couldn't add item.");
		}
		catch (TException e)
		{
			e.printStackTrace();
		}
	}
}
