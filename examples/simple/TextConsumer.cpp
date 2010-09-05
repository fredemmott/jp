#include "../../lib/cpp/consumer.h"

#include <iostream>

using namespace std;

class MyRunner : public jp::Runner<std::string>
{
	public:
		virtual bool operator()(const std::string& message)
		{
			cout << "I consumed a " << message << endl;
			return true;
		}
};

int main(int argc, char** argv)
{
	MyRunner runner;
	jp::TextConsumer p("text", &runner);
	p.run();
	return 0;
}
