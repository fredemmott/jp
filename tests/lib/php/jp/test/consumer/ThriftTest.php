<?php

$jpRoot = dirname(__FILE__) . '/../../../../../../';
require_once $jpRoot . 'lib/php/jp/consumer/Thrift.php';
require_once $jpRoot . 'examples/gen-php/example/example_types.php';
require_once 'Thrift/protocol/TBinaryProtocol.php';
require_once 'Thrift/transport/TMemoryBuffer.php';
require_once 'ConsumerTestCase.php';

/**
 * @package jp.test.consumer
 */
class jp_test_consumer_ThriftTest extends jp_test_consumer_ConsumerTestCase {
	/**
	 * @return void
	 */
	public function testRun() {
		/** @var $worker PHPUnit_Framework_MockObject_MockObject|jp_worker_Interface */
		$worker = $this->getMock('jp_worker_Interface');
		$worker->expects($this->exactly(5)) // expect 5 calls
			   ->method('processItem')
			   ->with($this->isInstanceOf('ExampleData'))
			   ->will($this->returnValue(true));

		/** @var $client PHPUnit_Framework_MockObject_MockObject|JobPoolIf */
		$client = $this->getMock('JobPoolIf');
		$client->expects($this->exactly(6)) // expect 6 calls (the 6th will result in an exception)
			   ->method('acquire')
			   ->will($this->returnCallback(array($this, 'mockAcquire')));

		$protocolFactory = new TBinaryProtocolFactory();
		$transport = new TMemoryBuffer();
		$protocol = $protocolFactory->getProtocol($transport);

		// Fill a mock queue backend
		for($i = 0; $i < 5; $i++) {
			/** @var $job PHPUnit_Framework_MockObject_MockObject|Job */
			$job = $this->getMock('Job');
			$doc = new ExampleData();
			$doc->language = 'php';
			$doc->api = 'simple' . $i;
			$doc->format = 'thrift';
			$doc->write($protocol);
			$message = $transport->read($transport->available());
			$job->message = $message;
			$job->id = $i;
			$this->addToQueueBackend($job);
		}

		$consumer = new jp_consumer_Thrift('foo', array('client' => $client, 'poll_interval' => 0), $worker, 'ExampleData');
		$this->assertEquals(5, $consumer->run());
	}
}