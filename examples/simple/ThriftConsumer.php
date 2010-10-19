#!/usr/bin/php
<?php

set_time_limit(0);

$jpRoot = dirname(__FILE__) . '/../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
$GLOBALS['THRIFT_ROOT'] = 'Thrift';
require_once('jp/consumer/Thrift.php');
require_once('jp/worker/Interface.php');
require_once(dirname(__FILE__) . '/../gen-php/example/example_types.php');

class ThriftQueueWorker implements jp_worker_Interface {
	public function processItem($message) {
		echo 'I consumed: ' . print_r($message, true);
		return true;
	}
}

$processor = new jp_consumer_Thrift('thrift', array('poll_interval' => 200), new ThriftQueueWorker(), 'ExampleData');
$processor->run();
