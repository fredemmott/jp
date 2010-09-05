#include "Jp.h"

#include <protocol/TBinaryProtocol.h>
#include <transport/TSocket.h>
#include <transport/TTransportUtils.h>

#include <iostream>

using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;

using boost::shared_ptr;

using namespace std;

int main(int argc, char** argv)
{
	shared_ptr<TTransport> socket(new TSocket("localhost", 9090));
	shared_ptr<TTransport> transport(new TBufferedTransport(socket));
	shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));
	JpClient client(protocol);
	transport->open();

	while(true)
	{
		try
		{
			Job job;
			client.acquire(job, "text");
			cout << "I'm consuming a " << job.message << "." << endl;
			client.purge("text", job.id);
			cout << "Consumed a " << job.message << "." << endl;
		}
		catch ( EmptyPool e)
		{
			cout << "Pool is empty." << endl;
			break;
		}
	}
	return 0;
}
