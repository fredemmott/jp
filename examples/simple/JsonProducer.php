#!/usr/bin/php
<?php

$jpRoot = dirname(__FILE__) . '/../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
require_once('jp/producer/Json.php');

$producer = new jp_producer_Json('json');
$doc = array('language' => 'php', 'api' => 'simple', 'format' => 'json');

for($i = 0; $i < 100; $i++) {
	$producer->add($doc);
}
