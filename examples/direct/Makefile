CPP_BINARIES=\
	TextProducer_cpp

all: $(CPP_BINARIES)

.PHONY: all clean

THRIFT_FLAGS=-I/usr/include/thrift -I../../gen-cpp/ -lthrift

%_cpp: %.cpp Makefile
	$(CXX) -o $@ $(CFLAGS) $(THRIFT_FLAGS) $< ../../gen-cpp/libjp.a

clean:
	rm *_cpp
