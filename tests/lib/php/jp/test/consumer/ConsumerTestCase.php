<?php

require_once dirname(__FILE__) . '/../BaseTestCase.php';
$jpRoot = dirname(__FILE__) . '/../../../../../../';
require_once $jpRoot . 'lib/php/jp/worker/Interface.php';

/**
 * @package jp.test.consumer
 */
class jp_test_consumer_ConsumerTestCase extends jp_test_BaseTestCase {
	/**
	 * @var array
	 */
	protected $queue = array();

	/**
	 * @return PHPUnit_Framework_MockObject_MockObject|Job
	 */
	public function mockAcquire() {
		if(count($this->queue) === 0) throw new EmptyPool();
		return array_shift($this->queue);
	}

	/**
	 * @param string $message
	 * @return void
	 */
	protected function addToQueueBackend($message) {
		$this->queue[] = $message;
	}
}