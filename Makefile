all: thrift lifecycle.png

.PHONY: all thrift

thrift: gen-rb/job_pool.rb gen-cpp/libjp.a gen-java/jp.jar

gen-rb/job_pool.rb: jp.thrift
	thrift --gen rb $<

gen-cpp/JobPool.cpp: jp.thrift
	thrift --gen cpp $<

gen-cpp/libjp.a: gen-cpp/JobPool.cpp
	cd gen-cpp; \
		$(CXX) $(CFLAGS) -c JobPool.cpp jp_constants.cpp jp_types.cpp -I/usr/include/thrift; \
		ar cq libjp.a *.o

gen-java/uk/co/fredemmott/jp/JobPool.java: jp.thrift
	thrift --gen java $<

THRIFT_JAR=/usr/share/java/libthrift.jar
SLF4J_JAR=/usr/share/java/slf4j-api.jar
gen-java/jp.jar: gen-java/uk/co/fredemmott/jp/JobPool.java
	cd gen-java; \
		find -name "*.java" | xargs javac -cp $(THRIFT_JAR):$(SLF4J_JAR); \
		find -name "*.class" | xargs jar cvf jp.jar;

lifecycle.png: lifecycle.dot
	dot -Tpng $< > $@
