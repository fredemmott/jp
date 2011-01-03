#!/usr/bin/php
<?php

set_time_limit(0);

$jpRoot = dirname(__FILE__) . '/../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
require_once('jp/consumer/Json.php');
require_once('jp/worker/Interface.php');

class JsonQueueWorker implements jp_worker_Interface {
	/**
	 * @param array $item
	 * @return void
	 */
	public function processItem($item) {
		echo 'I consumed: ' . print_r($item, true);
		return true;
	}
}

$processor = new jp_consumer_Json('json', array('poll_interval' => 200), new JsonQueueWorker());
$processor->run();
