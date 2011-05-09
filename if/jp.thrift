namespace rb Jp
namespace cpp jp
namespace java uk.co.fredemmott.jp

include 'fb303.thrift'

# Struct representing a job that's been acquired from a job pool
struct Job
{
	1:required binary message,
	2:required binary id # picked by the server
}

# Thrown when you attempt to acquire a job from a pool that is empty
exception EmptyPool
{
}

# Thrown when you attempt to access a non-existant pool
exception NoSuchPool
{
}

service JobPool extends fb303.FacebookService
{
	##### USER API #####

	# Add a message to a pool.
	void add(1:required string pool_name, 2:required binary message) throws (
		1:NoSuchPool nsp
	)

	# Lock a message in a pool, and retrieve it.
	# A locked message will not be given out again until a timeout is reached,
	# which is configured server-side.
	#
	# Not guaranteed to be atomic.
	Job acquire(1:required string pool_name) throws (
		1:NoSuchPool nsp,
		2:EmptyPool ep
	)
	
	# Remove a job from the pool.
	# Call from your consumer when you've finished a job, or from anywhere if
	# the job is no longer neccessary.
	#
	# If the job id is not recognized, then this call is a no-op.
	void purge(1:required string pool_name, 2:required binary id) throws (
		1:NoSuchPool nsp
	)
}

service JobPoolInstrumented extends JobPool
{
	##### ADMIN API #####

	list<string> pools()
	i64 start_time()

	i64 add_count(1:required string pool_name) throws ( 1:NoSuchPool nsp )
	i64 acquire_count(1:required string pool_name) throws ( 1:NoSuchPool nsp )
	i64 empty_count(1:required string pool_name) throws ( 1:NoSuchPool nsp )
	i64 purge_count(1:required string pool_name) throws ( 1:NoSuchPool nsp )
}
