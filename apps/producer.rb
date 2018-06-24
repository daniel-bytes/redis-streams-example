require 'redis'
require_relative '../lib/github_jobs'
require_relative '../lib/job_stream'

redis = Redis.new
jobs = GithubJobs.new
stream = JobStream.new(redis)

puts 'Streaming job data from Github'

File
  .readlines("#{File.dirname(__FILE__)}/../keywords.txt")
  .map { |keyword| keyword.strip! }
  .shuffle
  .each { |keyword|
    page = 0

    loop do
      puts "Fetching '#{keyword}' jobs, page #{page + 1}"
      found_jobs = jobs.fetch_jobs(keyword, page)

      puts "- #{found_jobs.size} jobs found"
      
      found_jobs.each do |job|
        puts "- #{job.company}: #{job.title}"
        stream.add_job(job)
        sleep Random.rand
      end

      break if found_jobs.size < 50
      
      page += 1
    end
  }

puts 'End of job data'
