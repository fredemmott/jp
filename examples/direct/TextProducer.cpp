#include "JobPool.h"

#include <protocol/TBinaryProtocol.h>
#include <transport/TSocket.h>
#include <transport/TTransportUtils.h>

#include <iostream>

using namespace jp;

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
	JobPoolClient client(protocol);
	transport->open();

	cout << "Adding a chicken..." << endl;
	client.add("text", "chicken");
	cout << "Added a chicken." << endl;
	return 0;
}
