<?php

/**
 * @package jp.worker
 */
interface jp_worker_Interface {
	/**
	 * @abstract
	 * @throws Exception
	 * @param string $item
	 * @return bool
	 */
	public function processItem($item);
}