require 'date'
require_relative './types'

##
# A struct representing aggregate data for jobs.
#
class JobAggregates < Dry::Struct::Value
  ##
  # Map type used to store aggregate counts for a job field type.
  #
  AggregateField = Types::Hash.map(
    Types::Coercible::String,
    Types::Coercible::Integer
  )

  attribute :created_at, AggregateField
  attribute :title, AggregateField
  attribute :location, AggregateField
  attribute :company, AggregateField

  ##
  # Fetches aggregates for a specific field key (:title, :location, etc).
  #
  def get(key)
    self.send(key)
  end

  ##
  # Converts a Redis hash result to a new JobAggregates instance.
  #
  def self.from_redis(hash)
    hash[:created_at] ||= {}
    hash[:title] ||= {}
    hash[:location] ||= {}
    hash[:company] ||= {}

    JobAggregates.new(
      created_at: AggregateField[hash[:created_at]],
      title: AggregateField[hash[:title]],
      location: AggregateField[hash[:location]],
      company: AggregateField[hash[:company]]
    )
  end
end
