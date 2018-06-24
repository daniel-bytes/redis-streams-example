require_relative './job'
require_relative './stream'

class JobStream
  def initialize(redis)
    @stream = Stream.new(redis)
  end

  ##
  # Clears the jobs stream
  #
  def clear!
    @stream.clear_stream!('github_jobs')
  end

  ##
  # Adds a job to the stream.
  #
  def add_job(job)
    @stream.add_message(job.to_message)
    job
  end

  ## 
  # Starts listening for Job messages.
  # This is a blocking operation.
  #
  def listen(start_index: 0)
    @stream.listen(github_jobs: start_index) do |message|
      yield Job.from_message(message)
    end
  end

  ##
  # Stops listening for jobs
  #
  def end_listen
    @stream.end_listen
  end
end
