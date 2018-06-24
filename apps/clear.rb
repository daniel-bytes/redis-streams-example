require 'redis'
require_relative '../lib/job_stream'
require_relative '../lib/job_aggregator'

redis = Redis.new
stream = JobStream.new(redis)
aggregator = JobAggregator.new(redis)

stream.clear!
aggregator.clear!
puts "all data cleared"
