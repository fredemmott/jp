#pragma once
#include <JobPool.h>
#include <protocol/TBinaryProtocol.h>
#include <transport/TSocket.h>
#include <transport/TTransportUtils.h>
#include <transport/TBufferTransports.h>

namespace jp
{
	using namespace jp;

	using namespace apache::thrift;
	using namespace apache::thrift::protocol;
	using namespace apache::thrift::transport;

	using boost::shared_ptr;

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
			virtual std::string translate(const T& message) const = 0;
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
			virtual std::string translate(const std::string& message) const
			{
				return message;
			}
	};

	template<typename T> class ThriftProducer : public AbstractProducer<T>
	{
		public:
			ThriftProducer(const std::string& pool, const std::string& hostname = DEFAULT_HOSTNAME, int port = DEFAULT_PORT)
			: AbstractProducer<T>(pool, hostname, port)
			{
				shared_ptr<TProtocolFactory> factory(new TBinaryProtocolFactory());
				m_transport = shared_ptr<TMemoryBuffer>(new TMemoryBuffer());
				m_protocol = factory->getProtocol(m_transport);
			}
		protected:
			virtual std::string translate(const T& message) const
			{
				m_transport->resetBuffer();
				message.write(&*m_protocol);
				uint32_t len = m_transport->available_read();
				uint8_t buf[len];
				m_transport->read(buf, len);
				std::string out(reinterpret_cast<char*>(buf), len);
				return out;
			}
		private:
			shared_ptr<TMemoryBuffer> m_transport;
			shared_ptr<TProtocol> m_protocol;
	};
}
