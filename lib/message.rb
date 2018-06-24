require 'pp'
require_relative './types'

##
# A message type, to be read/written by a Redis Stream
#
class Message < Dry::Struct::Value
  attribute :stream, Types::Strict::String
  attribute :id, Types::Strict::String.optional.default(nil)
  attribute :payload, Types::Hash.map(Types::Coercible::String, Types::Coercible::String)

  ##
  # Returns a copy of the current instance, with the ID set
  #
  def with_id(id)
    args = self.to_h
    args[:id] = id
    Message.new(args)
  end

  ##
  # Returns an array suitable for use as Redis XADD arguments
  #
  def to_xadd_args
    id = self.id ? self.id : '*'

    [:xadd, self.stream, id].concat(self.flat_payload)
  end

  ##
  # Returns the payload hash as a flat array
  #
  def flat_payload
    self.payload.to_a.flatten
  end

  ##
  # Parses the results of a Redis XREAD call
  # Returns an array of Messages
  #
  # Incoming data format:
  # [                               <- Array of streams
  #   [ "github_jobs",              <- Stream ID
  #     [                           <- Array of messages
  #       [ "1529250980039-0",      <- Message ID
  #         [ "id",                 <- Key/value tuples as a flat Array
  #           "a89d438c-70c6-11e8-9b37-9b2d31dd79c5",
  #           "created_at",
  #           "2018-06-15",
  #           "title",
  #           "Lead Data Engineer",
  #           "location",
  #           "New York",
  #           "company",
  #           "CrowdTwist"
  #         ]
  #       ]
  #     ]
  #   ]
  # ]
  #
  def self.from_xread_response(streams)
    [].tap do |results|
      streams.each do |stream|
        stream_name, messages = stream
        
        messages.each do |message|
          id, payload = message

          results << Message.new(
            id: id,
            stream: stream_name,
            payload: Hash[payload.each_slice(2).to_a]
          )
        end
      end
    end
  end
end
