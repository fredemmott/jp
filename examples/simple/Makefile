CPP_EXECUTABLES=\
	TextProducer_cpp \

all: $(CPP_EXECUTABLES) #$(JAVA_EXECUTABLES) $(JAVA_CLASSES)

.PHONY: all clean

THRIFT_FLAGS=-I/usr/include/thrift -I../../gen-cpp/ -lthrift
%_cpp: %.cpp
	$(CXX) -o $@ $(CFLAGS) $(THRIFT_FLAGS) $< ../../gen-cpp/libjp.a

clean:
	rm -f *_cpp
