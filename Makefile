all: thrift lifecycle.png

.PHONY: all thrift

thrift: gen-rb/jp.rb gen-cpp/Jp.cpp

gen-rb/jp.rb: jp.thrift
	thrift --gen rb $<

gen-cpp/Jp.cpp: jp.thrift
	thrift --gen cpp $<

lifecycle.png: lifecycle.dot
	dot -Tpng $< > $@
