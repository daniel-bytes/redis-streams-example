require_relative './job_aggregates'

##
# Job aggregate data collector and reporter.
#
class JobAggregator
  ##
  # Creates a new JobAggregator instance.
  #
  # @param redis - An instance of Redis
  #
  def initialize(redis)
    @redis = redis
  end

  ##
  # Processes a job for aggregate data.
  # Job will only be processed if the id is unique.
  #
  def process_job(job)
    return false unless new_job?(job)

    @redis.pipelined do
      JobAggregates.attribute_names.each do |field|
        @redis.hincrby("github_job_counters_#{field}", job.send(field), 1)
      end
    end

    true
  end

  ##
  # Loads all job aggregates data.
  #
  def get_aggregates
    JobAggregates.from_redis(
      JobAggregates.attribute_names.reduce({}) { |hash, field| 
        hash.tap { hash[field] = @redis.hgetall("github_job_counters_#{field}") }
      }
    )
  end

  ##
  # Clears the backend Redis fields used to store the aggregate data.
  #
  def clear!
    @redis.del('github_job_ids')
    JobAggregates.attribute_names.each { |field| @redis.del("github_job_counters_#{field}") }
  end

  private

  ##
  # Checks if a job is new by adding it to the processed jobs Redis set.
  #
  def new_job?(job)
    @redis.sadd('github_job_ids', job.id)
  end
end