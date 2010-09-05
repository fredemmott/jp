#include "../../lib/cpp/producer.h"

int main(int argc, char** argv)
{
	jp::TextProducer p("text");
	p.add("simple chicken");
	return 0;
}
