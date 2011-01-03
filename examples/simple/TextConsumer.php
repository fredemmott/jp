#!/usr/bin/php
<?php

set_time_limit(0);

$jpRoot = dirname(__FILE__) . '/../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
require_once('jp/consumer/Text.php');
require_once('jp/worker/Interface.php');

class TextQueueWorker implements jp_worker_Interface {
	public function processItem($item) {
		echo 'I consumed a ' . $item . PHP_EOL;
		return true;
	}
}

$consumer = new jp_consumer_Text('text', array('poll_interval' => 200), new TextQueueWorker());
$consumer->run();