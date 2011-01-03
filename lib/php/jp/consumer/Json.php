<?php

require_once 'jp/consumer/Abstract.php';

/**
 * @package jp.consumer
 */
class jp_consumer_Json extends jp_consumer_Abstract {
	/**
	 * @param string $message
	 * @return array
	 */
	protected function translate($message) {
		return json_decode($message, true);
	}
}