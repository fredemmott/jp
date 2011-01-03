<?php

require_once dirname(__FILE__) . '/../BaseTestCase.php';
$jpRoot = dirname(__FILE__) . '/../../../../../../';
require_once $jpRoot . 'lib/php/jp/producer/Thrift.php';
require_once $jpRoot . 'examples/gen-php/example/example_types.php';
require_once 'Thrift/protocol/TBinaryProtocol.php';
require_once 'Thrift/transport/TMemoryBuffer.php';

/**
 * @package jp.test.producer
 */
class jp_test_producer_ThriftTest extends jp_test_BaseTestCase {
	/**
	 * @return void
	 */
	public function testAdd() {
		$doc = new ExampleData();
		$doc->language = 'php';
		$doc->api = 'simple';
		$doc->format = 'thrift';

		$protocolFactory = new TBinaryProtocolFactory();
		$transport = new TMemoryBuffer();
		$protocol = $protocolFactory->getProtocol($transport);
		$doc->write($protocol);
		$message = $transport->read($transport->available());

		/** @var $client PHPUnit_Framework_MockObject_MockObject|JobPoolIf */
		$client = $this->getMock('JobPoolIf');
		$client->expects($this->once())
			   ->method('add')
			   ->with($this->equalTo('foo'), $this->equalTo($message));

		$consumer = new jp_producer_Thrift('foo', array('client' => $client));
		$consumer->add($doc);
	}
}