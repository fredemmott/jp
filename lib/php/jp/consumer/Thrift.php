<?php

require_once 'jp/consumer/Abstract.php';

/**
 * @throws InvalidArgumentException
 * @package jp.consumer
 */
class jp_consumer_Thrift extends jp_consumer_Abstract {
	/**
	 * @var TMemoryBuffer
	 */
	protected $_transport;

	/**
	 * @var TBinaryProtocol
	 */
	protected $_protocol;

	/**
	 * @var string
	 */
	protected $_className;

	/**
	 * @throws InvalidArgumentException
	 * @param string $queue
	 * @param array $options
	 * @param string $className
	 * @return void
	 */
	public function __construct($queue, $options = array(), jp_worker_Interface $worker = null, $className = '') {
		require_once 'Thrift/protocol/TBinaryProtocol.php';
		require_once 'Thrift/transport/TMemoryBuffer.php';
		if(empty($className)) throw new InvalidArgumentException();
		$protocolFactory = new TBinaryProtocolFactory();
		$this->_transport = new TMemoryBuffer();
		$this->_protocol = $protocolFactory->getProtocol($this->_transport);
		$this->_className = $className;
		parent::__construct($queue, $options, $worker);
	}

	/**
	 * @param string $message
	 * @return object
	 */
	protected function translate($message) {
		$class = new ReflectionClass($this->_className);
		$object = $class->newInstanceArgs();
		$this->_transport->write($message);
		$object->read($this->_protocol);
		return $object;
	}
}