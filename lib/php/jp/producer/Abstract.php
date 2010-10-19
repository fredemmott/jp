<?php

require_once 'jp/Client.php';

/**
 * @package jp.producer
 */
abstract class jp_producer_Abstract extends jp_Client {
	/**
	 * @param string $message
	 * @return void
	 */
	public function add($message) {
		return $this->_client->add($this->_queue, $this->translate($message));
	}

	/**
	 * @abstract
	 * @param string|array|object $message
	 * @return string
	 */
	abstract protected function translate($message);
}