CPP_EXECUTABLES=\
	TextConsumer_cpp \
	TextProducer_cpp \

JAVA_CLASSES=\
	TextConsumer.class \
	TextProducer.class \

JAVA_EXECUTABLES=$(subst .class,_java,$(JAVA_CLASSES))

all: $(CPP_EXECUTABLES) $(JAVA_EXECUTABLES) $(JAVA_CLASSES)

.PHONY: all clean

THRIFT_FLAGS=-I/usr/include/thrift -I../../gen-cpp/ -lthrift
%_cpp: %.cpp
	$(CXX) -o $@ $(CFLAGS) $(THRIFT_FLAGS) $< ../../gen-cpp/libjp.a

THRIFT_JAR=/usr/share/java/libthrift.jar
SLF4J_API_JAR=/usr/share/java/slf4j-api.jar
SLF4J_RUNTIME_JAR=/usr/share/java/slf4j-nop.jar

%.class: %.java
	javac $< -cp ../../gen-java/jp.jar:$(THRIFT_JAR):$(SLF4J_API_JAR)

%_java: Makefile
	echo "#!/bin/sh" > $@
	echo "java -cp ../../gen-java/jp.jar:$(THRIFT_JAR):$(SLF4J_RUNTIME_JAR):$(SLF4J_API_JAR):. $*" >> $@
	chmod 755 $@

clean:
	rm -f *_cpp *.class *_java
