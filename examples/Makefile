all: subdirs thrift

.PHONY: all subdirs thrift clean

thrift: gen-rb/example_types.rb gen-cpp/example_types.h

gen-rb/example_types.rb: example.thrift
	thrift --gen rb  $<

gen-cpp/example_types.h: example.thrift
	thrift --gen cpp $<

subdirs:
	$(MAKE) -C direct
	$(MAKE) -C simple

clean:
	$(MAKE) -C direct clean
	$(MAKE) -C simple clean
	rm -rf gen_*
