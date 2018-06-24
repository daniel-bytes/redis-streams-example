require_relative './types'
require_relative './message'

##
# A class for reading and writing Redis streams
#
class Stream
  ##
  # An error throw when calling listen on an already listening Stream
  class StreamAlreadyListeningError < StandardError; end
  
  ##
  # String => String mapping for a stream name and ID
  StreamAndId = Types::Hash.map(
    Types::Coercible::String,
    Types::Coercible::String
  )

  def initialize(redis, read_timeout_ms: 1000)
    @redis = redis
    @reading = false
    @read_timeout_ms = read_timeout_ms
  end

  ##
  # Deletes the stream
  #
  def clear_stream!(stream_name)
    @redis.del(stream_name)
  end

  ##
  # Adds a new message to the stream.
  #
  # @param messsage - The message to add to the stream
  # @return - The new message with the new ID set
  #
  def add_message(message)
    id = @redis.call(message.to_xadd_args)
    message.with_id(id)
  end

  ## 
  # Starts listening for messages.
  # This is a blocking operation.
  #
  # @param listen_streams - A hash with stream name as key and starting Id as value
  # 
  def listen(listen_streams)
    raise StreamAlreadyListeningError.new('Stream already listening') if @reading
    
    @reading = true
    streams = StreamAndId[listen_streams]

    while @reading
      results = @redis.call(
        [:xread, 'BLOCK', @read_timeout_ms, 'STREAMS']
          .concat(streams.keys)
          .concat(streams.keys.map { |k| streams[k] })
      )
      
      if (results)
        Message.from_xread_response(results).each do |message|
          streams[message.stream] = message.id
          yield message
        end
      end
    end
  end

  ##
  # Stops listening for messages
  #
  def end_listen
    @reading = false
  end
end