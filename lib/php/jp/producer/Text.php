<?php

require_once 'jp/producer/Abstract.php';

/**
 * @package jp.producer
 */
class jp_producer_Text extends jp_producer_Abstract {
	/**
	 * @param string $message
	 * @return string
	 */
	protected function translate($message) {
		return $message;
	}
}