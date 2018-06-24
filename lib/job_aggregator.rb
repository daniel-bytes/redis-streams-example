require_relative './job_aggregates'

class JobAggregator
  def initialize(redis)
    @redis = redis
  end

  def process_job(job)
    return false unless new_job?(job)

    @redis.pipelined do
      JobAggregates.attribute_names.each do |field|
        @redis.hincrby("github_job_counters_#{field}", job.send(field), 1)
      end
    end

    true
  end

  def get_aggregates
    JobAggregates.from_redis(
      JobAggregates.attribute_names.reduce({}) { |hash, field| 
        hash.tap { hash[field] = @redis.hgetall("github_job_counters_#{field}") }
      }
    )
  end

  def clear!
    @redis.del('github_job_ids')
    JobAggregates.attribute_names.each { |field| @redis.del("github_job_counters_#{field}") }
  end

  private

  def new_job?(job)
    @redis.sadd('github_job_ids', job.id)
  end
end