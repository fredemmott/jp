import org.apache.thrift.TException;
import org.apache.thrift.transport.TTransport;
import org.apache.thrift.transport.TSocket;
import org.apache.thrift.transport.TTransportException;
import org.apache.thrift.protocol.TBinaryProtocol;
import org.apache.thrift.protocol.TProtocol;
import uk.co.fredemmott.jp.*;

public class TextConsumer
{
	public static void main(String[] args)
	{
		try
		{
			TTransport transport = new TSocket("localhost", 9090);
			TProtocol protocol = new TBinaryProtocol(transport);
			JobPool.Client client = new JobPool.Client(protocol);

			transport.open();

			while(true)
			{
				Job job = client.acquire("text");
				System.out.print("I'm consuming a ");
				System.out.println(new String(job.message, "UTF-8"));
				client.purge("text", job.id);
				System.out.println("Consumed.");
			}
		}
		catch (java.io.UnsupportedEncodingException e)
		{
			System.out.println("UTF-8 encoding not supported, couldn't process item.");
		}
		catch (NoSuchPool e)
		{
			System.out.println("Pool 'text' does not exist, couldn't acquire item.");
		}
		catch (EmptyPool e)
		{
			System.out.println("Pool is empty :(");
		}
		catch (TException e)
		{
			e.printStackTrace();
		}
	}
}
