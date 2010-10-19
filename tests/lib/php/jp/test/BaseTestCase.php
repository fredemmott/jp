<?php

$GLOBALS['THRIFT_ROOT'] = 'Thrift';
$jpRoot = dirname(__FILE__) . '/../../../../../';
set_include_path(get_include_path() . PATH_SEPARATOR . $jpRoot . 'lib/php' . PATH_SEPARATOR . $jpRoot . 'gen-php/jp');
require_once 'PHPUnit/Framework/TestCase.php';
require_once $jpRoot . 'gen-php/jp/JobPool.php';
require_once $jpRoot . 'gen-php/jp/jp_types.php';

/**
 * @package jp.test
 */
class jp_test_BaseTestCase extends PHPUnit_Framework_TestCase {
	// Empty for now.
}