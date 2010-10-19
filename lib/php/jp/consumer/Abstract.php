<?php

require_once 'jp/Client.php';

/**
 * @package jp.consumer
 */
abstract class jp_consumer_Abstract extends jp_Client {
	/**
	 * @var jp_worker_Interface
	 */
	protected $_worker;

	/**
	 * @throws InvalidArgumentException
	 * @param string $queue
	 * @param array $options
	 * @param jp_worker_Abstract $worker
	 * @return void
	 */
	public function __construct($queue, $options = array(), jp_worker_Interface $worker = null) {
		if(!$worker) throw new InvalidArgumentException('Expecting worker');
		if(!isset($options['poll_interval'])) $options['poll_interval'] = 1000000;
		else $options['poll_interval'] = $options['poll_interval'] * 1000;
		$this->_worker = $worker;
		parent::__construct($queue, $options);
	}

	/**
	 * @return int
	 */
	public function run() {
		$i = 0;

		try {
			while(true) {
				$this->consume();
				if($this->_options['poll_interval'] > 0) usleep($this->_options['poll_interval']);
				++$i;
			}
		}
		catch(EmptyPool $e) { }

		return $i;
	}

	/**
	 * @return void
	 */
	protected function consume() {
		$job = $this->_client->acquire($this->_queue);
		$result = $this->_worker->processItem($this->translate($job->message));
		if($result) $this->_client->purge($this->_queue, $job->id);
	}

	/**
	 * @abstract
	 * @param string $message
	 * @return void
	 */
	abstract protected function translate($message);
}