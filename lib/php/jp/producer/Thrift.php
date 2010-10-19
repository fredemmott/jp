<?php

require_once 'jp/producer/Abstract.php';

/**
 * @package jp.producer
 */
class jp_producer_Thrift extends jp_producer_Abstract {
	/**
	 * @var TMemoryBuffer
	 */
	protected $_transport;

	/**
	 * @var TBinaryProtocol
	 */
	protected $_protocol;

	/**
	 * @param string $queue
	 * @param array $options
	 * @return void
	 */
	public function __construct($queue, $options = array()) {
		require_once 'Thrift/protocol/TBinaryProtocol.php';
		require_once 'Thrift/transport/TMemoryBuffer.php';
		$protocolFactory = new TBinaryProtocolFactory();
		$this->_transport = new TMemoryBuffer();
		$this->_protocol = $protocolFactory->getProtocol($this->_transport);
		parent::__construct($queue, $options);
	}

	/**
	 * @param object $message
	 * @return string
	 */
	protected function translate($message) {
		$message->write($this->_protocol);
		return $this->_transport->read($this->_transport->available());
	}
}