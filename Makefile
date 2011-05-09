default: thrift

all: thrift docs examples lib test

docs: lifecycle.png javadoc

thrift:  thrift-rb thrift-cpp thrift-java

lib: lib-java

##### THRIFT-RB #####

thrift-rb: gen-rb/jp_types.rb gen-rb/fb303_types.rb

gen-rb/%_types.rb: if/%.thrift
	thrift --gen rb $<

##### THRIFT-CPP #####

thrift-cpp: gen-cpp/libjp.a

gen-cpp/%_types.h: if/%.thrift
	thrift --gen cpp $<

gen-cpp/libjp.a: gen-cpp/jp_types.h gen-cpp/fb303_types.h
	cd gen-cpp; \
		$(CXX) $(CFLAGS) -c -I/usr/include/thrift \
			JobPool.cpp jp_constants.cpp jp_types.cpp \
			FacebookService.cpp fb303_constants.cpp fb303_types.cpp ;\
		ar cq libjp.a *.o

###### THRIFT-JAVA #####

thrift-java: gen-java/jp.jar

gen-java/uk/co/fredemmott/jp/JobPool.java: if/jp.thrift
	thrift --gen java $<

gen-java/com/facebook/fb303/FacebookService.java: if/fb303.thrift
	thrift --gen java $<

THRIFT_JAR=/usr/share/java/libthrift.jar
SLF4J_JAR=/usr/share/java/slf4j-api.jar
gen-java/jp.jar: gen-java/uk/co/fredemmott/jp/JobPool.java gen-java/com/facebook/fb303/FacebookService.java
	cd gen-java; \
		find . -name "*.java" | xargs javac -cp $(THRIFT_JAR):$(SLF4J_JAR); \
		find . -name "*.class" | xargs jar cvf jp.jar;

##### LIB-JAVA #####

lib-java:
	ant jar

##### TESTS #####
test: test-server test-lib

test-server:
	cd tests/classes; ./run_tests.rb

test-lib: test-lib-rb test-lib-java

test-lib-rb:
	cd tests/lib/rb; ./run_tests.rb

test-lib-java:
	ant junit 2>&1 | ruby -e "exit_code = 0; while gets; exit_code = 1 if /FAILED/; print; end; exit exit_code"

##### MISC #####

lifecycle.png: lifecycle.dot
	dot -Tpng $< > $@

javadoc:
	ant javadoc

examples: thrift lib
	$(MAKE) -C examples
	ant compile_examples create_scripts

clean: clean-java clean-thrift
	$(MAKE) -C examples clean
	rm -rf lifecycle.png

clean-thrift:
	rm -rf gen-*

clean-java:
	ant clean
