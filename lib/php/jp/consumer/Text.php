<?php

require_once 'jp/consumer/Abstract.php';

/**
 * @package jp.consumer
 */
class jp_consumer_Text extends jp_consumer_Abstract {
	/**
	 * @param string $message
	 * @return string
	 */
	protected function translate($message) {
		return $message;
	}
}