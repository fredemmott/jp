$LOAD_PATH.unshift File.dirname(__FILE__) + '/gen-rb'
require 'job_pool'
require 'job_pool_instrumented'
$LOAD_PATH.shift
