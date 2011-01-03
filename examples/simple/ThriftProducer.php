#!/usr/bin/php
<?php

$jpRoot = dirname(__FILE__) . '/../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
$GLOBALS['THRIFT_ROOT'] = 'Thrift';
require_once('jp/producer/Thrift.php');
require_once(dirname(__FILE__) . '/../gen-php/example/example_types.php');

$producer = new jp_producer_Thrift('thrift');
$doc = new ExampleData();
$doc->language = 'php';
$doc->api = 'simple';
$doc->format = 'thrift';

for($i = 0; $i < 100; $i++) {
	$producer->add($doc);
}
