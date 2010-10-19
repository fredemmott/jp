<?php

require_once 'PHPUnit/Framework/TestSuite.php';

/**
 * @package jp.test
 */
class jp_test_TestSuite {
	/**
	 * @static
	 * @return void
	 */
	public static function suite() {
		$suite = new PHPUnit_Framework_TestSuite('jp');
		$iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator(dirname(__FILE__)), RecursiveIteratorIterator::SELF_FIRST);

		/** @var $file DirectoryIterator */
		foreach ($iterator as $file) {
			if($file->isFile() && substr($file->getPathname(), -8) === 'Test.php') $suite->addTestFile($file->getPathname());
		}

		return $suite;
	}
}