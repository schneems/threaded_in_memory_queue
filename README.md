## Threaded

[![Build Status](https://travis-ci.org/schneems/threaded.png?branch=master)](https://travis-ci.org/schneems/threaded)
[![Help Contribute to Open Source](https://www.codetriage.com/schneems/threaded_in_memory_queue/badges/users.svg)](https://www.codetriage.com/schneems/threaded_in_memory_queue)


A simple non-durable in memory queue for running background tasks using threads.

## Why

Projects like [Resque](https://github.com/resque/resque), [delayed job](https://github.com/collectiveidea/delayed_job), [queue classic](https://github.com/ryandotsmith/queue_classic), and [sidekiq](https://github.com/mperham/sidekiq) are great. They use data stores like postgres and redis to store information to be processed later. If you're prototyping a system or don't have access to a data store, you might still want to push off some work to a background process. If that's the case an in-memory threaded queue might be a good fit.

## Install

In your `Gemfile`:

```ruby
gem 'threaded'
```

Then run `$ bundle install`

## Use it

Define your task to be processed:

```ruby
class Archive
  def self.call(repo_id, branch = 'master')
    repo = Repository.find(repo_id)
    repo.create_archive(branch)
  end
end
```

It can be any object that responds to `call` but we recommend a class or module which makes switching to a durable queue later easier.

Then to enqueue a task to be run in the background use `Threaded.enqueue`:

```ruby
repo = Repo.last
Threaded.enqueue(Archive, repo.id, 'staging')
```

The first argument is a class that defines the task to be processed and the rest of the arguments are passed to the task when it is run.



# Configure

The default number of worker threads is 16, you can configure that when you start your queue:

```ruby
Threaded.config do |config|
  config.size = 5
end
```

By default jobs have a timeout value of 60 seconds. Since this is an in-memory queue (goes away when your process terminates) it is in your best interests to keep jobs small and quick, and not overload the queue. You can configure a different timeout on start:

```ruby
Threaded.config do |config|
  config.timeout = 90 # timeout is in seconds
end
```

Want a different logger? Specify a different Logger:

```ruby
Threaded.config do |config|
  config.logger = Logger.new(STDOUT)
end
```

As soon as you call `enqueue` a new thread will be started, if you wish to explicitly start all threads you can call `Threaded.start`. You can also inline your config if you want when you start the queue:

```ruby
Threaded.start(size: 5, timeout: 90, logger: Logger.new(STDOUT))
```

For testing or guaranteed code execution use the `inline` option:

```ruby
Threaded.inline = true
```

This option bypasses the queue and executes code as it comes.

## Thread Considerations

This worker operates in the same process as your app, that means if your app is CPU bound, it will not be very useful. This worker uses threads which means that to be useful your app needs to either use IO (database calls, file writes/reads, shelling out, etc.) or run on JRuby or Rubinius.

To make sure all items in your queue are processed you can add a condition `at_exit` to your program:

```ruby
at_exit do
  Threaded.stop
end
```

This call takes an optional timeout value (in seconds).

```ruby
Threaded.stop(42)
```

## License

MIT

