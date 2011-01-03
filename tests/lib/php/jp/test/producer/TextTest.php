<?php

require_once dirname(__FILE__) . '/../BaseTestCase.php';
$jpRoot = dirname(__FILE__) . '/../../../../../../';
require_once $jpRoot . 'lib/php/jp/producer/Text.php';

/**
 * @package jp.test.producer
 */
class jp_test_producer_TextTest extends jp_test_BaseTestCase {
	/**
	 * @return void
	 */
	public function testAdd() {
		$message = 'foo bar baz';

		/** @var $client PHPUnit_Framework_MockObject_MockObject|JobPoolIf */
		$client = $this->getMock('JobPoolIf');
		$client->expects($this->once())
			   ->method('add')
			   ->with($this->equalTo('foo'), $this->equalTo($message));

		$consumer = new jp_producer_Text('foo', array('client' => $client));
		$consumer->add($message);
	}
}