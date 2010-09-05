#include "../../lib/cpp/consumer.h"
#include <example_types.h>

#include <iostream>
using namespace std;

class MyRunner : public jp::Runner<ExampleData>
{
	public:
		virtual bool operator()(const ExampleData& message)
		{
			cout << "Received:" << endl;
			cout << " - Language: " << message.language << endl;
			cout << " - API:      " << message.api << endl;
			cout << " - Format:   " << message.format << endl;
			return true;
		}
};

int main(int argc, char** argv)
{
	MyRunner runner;
	jp::ThriftConsumer<ExampleData> p("thrift", &runner);
	p.run();
	return 0;
}
