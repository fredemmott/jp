<?php

require_once 'jp/producer/Abstract.php';

/**
 * @package jp.producer
 */
class jp_producer_Json extends jp_producer_Abstract {
	/**
	 * @param array $message
	 * @return string
	 */
	protected function translate($message) {
		return json_encode($message);
	}
}