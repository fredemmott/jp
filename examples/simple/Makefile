CPP_EXECUTABLES=\
	TextConsumer_cpp \
	TextProducer_cpp \
	ThriftProducer_cpp \

all: $(CPP_EXECUTABLES) #$(JAVA_EXECUTABLES) $(JAVA_CLASSES)

.PHONY: all clean

THRIFT_FLAGS=-I/usr/include/thrift -I../../gen-cpp/ -I../gen-cpp/ -lthrift
LIBEVENT_FLAGS=-levent

%_cpp: %.cpp
	$(CXX) -o $@ $(CFLAGS) $(THRIFT_FLAGS) $(LIBEVENT_FLAGS) ../gen-cpp/*.cpp $< ../../gen-cpp/libjp.a

clean:
	rm -f *_cpp
