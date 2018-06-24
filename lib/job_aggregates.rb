require 'date'
require_relative './types'

##
# A struct representing a Job on Github jobs API
#
class JobAggregates < Dry::Struct::Value
  AggregateField = Types::Hash.map(
    Types::Coercible::String,
    Types::Coercible::Integer
  )

  attribute :created_at, AggregateField
  attribute :title, AggregateField
  attribute :location, AggregateField
  attribute :company, AggregateField

  def get(key)
    self.send(key)
  end

  ##
  # Converts a Redis hash to a new JobAggregates
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
