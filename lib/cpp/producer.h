#pragma once
#include <JobPool.h>
#include <protocol/TBinaryProtocol.h>
#include <transport/TSocket.h>
#include <transport/TTransportUtils.h>

using namespace jp;

using namespace apache::thrift;
using namespace apache::thrift::protocol;
using namespace apache::thrift::transport;

using boost::shared_ptr;

namespace jp
{
	static const char* DEFAULT_HOSTNAME = "localhost";
	static const int DEFAULT_PORT = 9090;

	template<typename T> class AbstractProducer
	{
		public:
			AbstractProducer(const std::string& pool, const std::string& hostname, int port)
			{
				m_pool = pool;

				shared_ptr<TTransport> socket(new TSocket(hostname, port));
				shared_ptr<TTransport> transport(new TBufferedTransport(socket));
				shared_ptr<TProtocol> protocol(new TBinaryProtocol(transport));
				m_client = new JobPoolClient(protocol);

				transport->open();
			}
		
			~AbstractProducer()
			{
				delete m_client;
			}

			void add(const T& message)
			{
				m_client->add(m_pool, translate(message));
			}
		protected:
			virtual std::string translate(const T& message) = 0;
		private:
			JobPoolClient* m_client;
			std::string m_pool;
	};

	class TextProducer : public AbstractProducer<std::string>
	{
		public:
			TextProducer(const std::string& pool, const std::string& hostname = DEFAULT_HOSTNAME, int port = DEFAULT_PORT)
			: AbstractProducer<std::string>(pool, hostname, port)
			{
			}
		protected:
			virtual std::string translate(const std::string& message)
			{
				return message;
			}
	};
}
