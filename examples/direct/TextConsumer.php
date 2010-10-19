#!/usr/bin/php
<?php

require_once('Thrift/Thrift.php');
require_once('Thrift/protocol/TBinaryProtocol.php');
require_once('Thrift/transport/TSocket.php');
require_once('Thrift/transport/TBufferedTransport.php');
require_once(dirname(__FILE__). '/../../gen-php/jp/JobPool.php');

$socket = new TSocket('localhost', 9090);
$transport = new TBufferedTransport($socket);
$protocol = new TBinaryProtocol($transport);
$pool = new JobPoolClient($protocol);
$transport->open();

while(true) {
	try {
		$job = $pool->acquire('text');
		echo 'I\'m consuming a ' . $job->message . PHP_EOL;
		$pool->purge('text', $job->id);
		echo 'I consumed a ' . $job->message . PHP_EOL;
	}
	catch (EmptyPool $e) {
		echo 'Pool is empty :(' . PHP_EOL;
		break;
	}
	catch (Exception $e) {
		echo $e;
		exit;
	}
}

$transport->close();

?>
