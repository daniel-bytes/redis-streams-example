require 'date'
require_relative './types'
require_relative './message'

##
# A struct representing a job post.
#
class Job < Dry::Struct::Value
  attribute :id, Types::Strict::String
  attribute :created_at, Types::Strict::Date
  attribute :title, Types::Strict::String
  attribute :location, Types::Strict::String
  attribute :company, Types::Strict::String

  ##
  # Converts the current Job to a Message.
  #
  def to_message
    Message.new(
      stream: 'github_jobs',
      payload: self.to_h
    )
  end

  ##
  # Converts a stream Message to a new Job instance.
  #
  def self.from_message(message)
    payload = message.payload

    Job.new(
      id: payload['id'],
      created_at: DateTime.parse(payload['created_at']).to_date,
      title: payload['title'],
      location: payload['location'],
      company: payload['company']
    )
  end
end
