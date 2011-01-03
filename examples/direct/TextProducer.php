#!/usr/bin/php
<?php

require_once('Thrift/Thrift.php');
require_once('Thrift/protocol/TBinaryProtocol.php');
require_once('Thrift/transport/TSocket.php');
require_once('Thrift/transport/TBufferedTransport.php');
require_once(dirname(__FILE__). '/../../gen-php/jp/JobPool.php');

try {
	$socket = new TSocket('localhost', 9090);
	$transport = new TBufferedTransport($socket);
	$protocol = new TBinaryProtocol($transport);
	$pool = new JobPoolClient($protocol);
	
	$transport->open();
	echo 'Adding a pie...' . PHP_EOL;
	$pool->add('text', 'pie');
	echo 'I added a pie' . PHP_EOL;
	$transport->close();
}
catch (Exception $e) {
	echo $e;
	exit;
}

?>
