<?php

require_once dirname(__FILE__) . '/../BaseTestCase.php';
$jpRoot = dirname(__FILE__) . '/../../../../../../';
require_once $jpRoot . 'lib/php/jp/producer/Json.php';

/**
 * @package jp.test.producer
 */
class jp_test_producer_JsonTest extends jp_test_BaseTestCase {
	/**
	 * @return void
	 */
	public function testAdd() {
		$message = array('foo' => 'bar', 'baz');

		/** @var $client PHPUnit_Framework_MockObject_MockObject|JobPoolIf */
		$client = $this->getMock('JobPoolIf');
		$client->expects($this->once())
			   ->method('add')
			   ->with($this->equalTo('foo'), $this->equalTo(json_encode($message)));

		$consumer = new jp_producer_Json('foo', array('client' => $client));
		$consumer->add($message);
	}
}