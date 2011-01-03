<?php

/**
 * @throws InvalidArgumentException
 * @package jp
 */
abstract class jp_Client {
	/**
	 * @var array
	 */
	protected $_options = array();

	/**
	 * @var string
	 */
	protected $_queue;

	/**
	 * @var JobPoolClient|object
	 */
	protected $_client;

	/**
	 * @throws InvalidArgumentException
	 * @param string $queue
	 * @param array $options
	 * @return void
	 */
	public function __construct($queue, $options = array()) {
		if(!isset($options['host'])) $options['host'] = 'localhost';
		if(!isset($options['port'])) $options['port'] = 9090;
		if(!is_string($queue)) throw new InvalidArgumentException();

		$this->_queue = $queue;
		$this->_options = $options;

		if(isset($options['client'])) {
			$this->_client = $this->_options['client'];
		}
		else {
			require_once 'Thrift/Thrift.php';
			require_once 'Thrift/protocol/TBinaryProtocol.php';
			require_once 'Thrift/transport/TSocket.php';
			require_once 'Thrift/transport/TBufferedTransport.php';
			require_once 'JobPool.php';
			
			$socket = new TSocket($this->_options['host'], $this->_options['port']);
			$transport = new TBufferedTransport($socket);
			$protocol = new TBinaryProtocol($transport);
			$this->_client = new JobPoolClient($protocol);
			$transport->open();
		}
	}
}