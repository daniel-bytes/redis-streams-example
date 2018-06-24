require 'date'
require 'httparty'
require_relative './job'

##
# A class for fetching jobs from the public Github jobs API
#
class GithubJobs
  include HTTParty
  base_uri 'http://jobs.github.com'

  ##
  # Fetch jobs matching the given keyword
  #
  # @param keyword - The keyword to search
  # @param page - Optional page number (starting at zero)
  # @return - An array of Job objects
  #
  def fetch_jobs(keyword, page = 0)
    self.class.get("/positions.json?description=#{keyword}&page=#{page}").map do |j|
      Job.new(
        id: j['id'],
        created_at: DateTime.parse(j['created_at']).to_date,
        title: j['title'],
        location: j['location'],
        type: j['type'],
        company: j['company']
      )
    end
  end
end