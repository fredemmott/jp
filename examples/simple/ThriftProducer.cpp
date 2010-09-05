#include "../../lib/cpp/producer.h"
#include <example_types.h>

int main(int argc, char** argv)
{
	jp::ThriftProducer<ExampleData> p("thrift");

	ExampleData doc;
	doc.language = "C++";
	doc.api = "simple";
	doc.format = "Thrift";

	p.add(doc);
	return 0;
}
