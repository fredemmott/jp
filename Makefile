all: thrift lifecycle.png

.PHONY: all thrift

thrift: gen-rb/job_pool.rb gen-cpp/libjp.a

gen-rb/job_pool.rb: jp.thrift
	thrift --gen rb $<

gen-cpp/JobPool.cpp: jp.thrift
	thrift --gen cpp $<

gen-cpp/libjp.a: gen-cpp/JobPool.cpp
	cd gen-cpp; \
		$(CXX) $(CFLAGS) -c JobPool.cpp jp_constants.cpp jp_types.cpp -I/usr/include/thrift; \
		ar cq libjp.a *.o

lifecycle.png: lifecycle.dot
	dot -Tpng $< > $@
