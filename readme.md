# Redis Streams Producer/Consumer Demo

Simple data pipeline example using Redis Streams for connecting producers and consumers and using Redis for incrementing counters for aggregating data.  The example application fetches data from the public Github Jobs API and produces job data on a Redis Stream, while the consumer side reads data from the stream and aggregates the jobs by various fields.

This application requires Redis 5.0 or later.

## Producer

The producer application is used to download jobs from Github and publish on the Redis `github_jobs` stream.  The producer makes no effort to deduplicate jobs, it is up to the consumer to ensure that the same job is not processed multiple times.

Ex:

```
ruby ./apps/producer.rb
```

## Consumer

The consumer application reads from the Redis stream and aggregates the jobs based on several attributes (`title`, `location`, etc).  The consumer will only process jobs with a unique job `id` field (using a Redis set to track unique jobs).  The aggregations are done stored in a Redis hash and incremented using the Redis `HINCRBY` command.

Ex:

```
ruby ./apps/consumer.rb
```

Note the consumer can take an optional command line argument to select which field is printed.  By default this is `location`, but it can also be set to `created_at`,  `title` or `company`.

Ex:

```
ruby ./apps/consumer.rb title
```

## Clearing all data

Just a simple script to clear all data from Redis.

Ex:

```
ruby ./apps/clear.rb
```

