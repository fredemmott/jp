#!/usr/bin/env ruby

require 'jp/thrift'
require 'jp/server/handler'
require 'jp_unlocker'
require 'ruby-1.9.0-compat'

require 'mongo'
include Jp

class JpServer < Jp::Server::Handler
  def initialize options = {}
    super options
    options[:port_number] ||= 9090

    # Setup Thrift server (allowing dependency injection)
    if options.member? :injected_thrift_server then
      @server = options[:injected_thrift_server]
    else
      processor = options[:thrift_processor] # For testing, and allow instrumented server to override
      processor ||= JobPool::Processor.new self
      socket = Thrift::ServerSocket.new options[:port_number]
      transportFactory = Thrift::BufferedTransportFactory.new

      @server = Thrift::ThreadedServer.new processor, socket, transportFactory
    end

    @unlocker = nil
    unless options[:skip_embedded_unlocker]
      if options.member? :injected_unlocker
        @unlocker = options[:injected_unlocker]
      else
        @unlocker = JpUnlocker.new options
      end
    end

    @start_time = Time.new.to_i
  end

  def serve
    # Look for expired entries
    @unlocker ||= nil
    unlocker_thread = nil
    if @unlocker
      unlocker_thread = Thread.new do
        @unlocker.run
      end
    end
    @server.serve
    unlocker_thread.join if unlocker_thread
  end


  # fb303:
  def getName; 'jp'; end
  def getVersion; '0.0.1'; end
  def getStatus; Fb_status::ALIVE; end
  def getStatusDetails; 'nothing to see here; move along'; end
  def aliveSince; @start_time; end
  def shutdown
    STDERR.write "Shutdown requested via fb303\n"
    exit
  end
  # fb303 stubs:
  def setOption(key, value); end
  def getOption(key); end
  def getOptions; Hash.new; end
  def getCpuProfile(seconds); String.new; end
  def reinitialize; end
  # fb303 stubs properly implemented in JpInstrumentedServer:
  def getCounters; Hash.new; end
  def getCounter(name); 0; end
end
