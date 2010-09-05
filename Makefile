all: thrift lifecycle.png

.PHONY: all thrift

thrift: gen-rb/jp.rb gen-cpp/libjp.a

gen-rb/jp.rb: jp.thrift
	thrift --gen rb $<

gen-cpp/Jp.cpp: jp.thrift
	thrift --gen cpp $<

gen-cpp/libjp.a: gen-cpp/Jp.cpp
	cd gen-cpp; \
		$(CXX) $(CFLAGS) -c Jp.cpp jp_constants.cpp jp_types.cpp -I/usr/include/thrift; \
		ar cq libjp.a *.o

lifecycle.png: lifecycle.dot
	dot -Tpng $< > $@
