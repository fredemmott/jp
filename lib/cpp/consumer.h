#pragma once
#include <JobPool.h>
#include <protocol/TBinaryProtocol.h>
#include <transport/TSocket.h>
#include <transport/TTransportUtils.h>
#include <transport/TBufferTransports.h>

#ifndef WITHOUT_JP_RUN
#define WITH_JP_LIBEVENT
#endif

#ifdef WITH_JP_LIBEVENT
#include <event.h>
#endif

namespace jp
{
	using namespace jp;
	
	using namespace apache::thrift;
	using namespace apache::thrift::protocol;
	using namespace apache::thrift::transport;
	
	using boost::shared_ptr;

	static const char* DEFAULT_HOSTNAME = "localhost";
	static const int DEFAULT_PORT = 9090;
	static const int DEFAULT_POLL_INTERVAL = 1;

	template<typename T> class Runner
	{
		public:
			virtual bool operator()(const T& message) = 0;
	};

	template<typename T> class AbstractConsumer
	{
		public:
			AbstractConsumer(const std::string& pool, Runner<T>* runner, const std::string& hostname, int port, int pollInterval)
			{
				m_runner = runner;
				m_pool = pool;
				m_pollInterval = pollInterval;

				shared_ptr<TTransport> socket(new TSocket(hostname, port));
				shared_ptr<TTransport> transport(new TBufferedTransport(socket));
				shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));
				m_client = new JobPoolClient(protocol);

				transport->open();
			}
		
			~AbstractConsumer()
			{
				delete m_client;
			}

			int poll()
			{
				int i = 0;
				try
				{
					while(true)
					{
						consume();
					}
				}
				catch(EmptyPool e)
				{
					return i;
				}
				// Unreachable, but stop the compiler giving a warning
				return i;
			}

#ifdef WITH_JP_LIBEVENT
			void run()
			{
				event_base* base = event_init();

				m_tv.tv_usec = 0;
				m_tv.tv_sec = m_pollInterval;
				evtimer_set(&m_ev, timerCallback, this);
				evtimer_add(&m_ev, &m_tv);

				event_dispatch();

				event_base_free(base);
			}
#endif
		protected:
			virtual T translate(const std::string& message) const = 0;
		private:
			void consume()
			{
				Job job;
				m_client->acquire(job, m_pool);
				if((*m_runner)(translate(job.message)))
				{
					m_client->purge(m_pool, job.id);
				}
			}
#ifdef WITH_JP_LIBEVENT
			static void timerCallback(int /*fd*/, short /*event*/, void* arg)
			{
				AbstractConsumer* consumer = static_cast<AbstractConsumer*>(arg);
				consumer->poll();
				evtimer_add(&consumer->m_ev, &consumer->m_tv);
			}

			event m_ev;
			timeval m_tv;
#endif

			JobPoolClient* m_client;
			Runner<T>* m_runner;
			std::string m_pool;
			int m_pollInterval;
	};

	class TextConsumer : public AbstractConsumer<std::string>
	{
		public:
			TextConsumer(const std::string& pool, Runner<std::string>* runner, const std::string& hostname = DEFAULT_HOSTNAME, int port = DEFAULT_PORT, int pollInterval = DEFAULT_POLL_INTERVAL)
			: AbstractConsumer<std::string>(pool, runner, hostname, port, pollInterval)
			{
			}
		protected:
			std::string translate(const std::string& message) const
			{
				return message;
			}
	};
}
