require 'redis'
require 'terminal-table'
require_relative '../lib/job_stream'
require_relative '../lib/job_aggregates'
require_relative '../lib/job_aggregator'

FIELD = ARGV.size > 0 ? ARGV[0].to_sym : :location

def build_table(aggregates)
  total = 0
  Terminal::Table.new do |t|
    field_aggs = aggregates.get(FIELD)

    field_aggs.keys.each do |key|
      location_count = field_aggs[key]
      
      t << [key, location_count]

      total += location_count
    end

    if total > 0
      t.add_separator
      t << ['Total', total]
    end
  end
end


redis = Redis.new
stream = JobStream.new(redis)
aggregator = JobAggregator.new(redis)

trap("SIGINT") do
  stream.end_listen
  exit
end

puts "Listening for messages"
puts "Press ctrl + c to end"
stream.listen do |job|
  if aggregator.process_job(job)
    table = build_table(aggregator.get_aggregates)
    system "clear" or system "cls"
    puts table
  end
end


