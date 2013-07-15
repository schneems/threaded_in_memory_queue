## Threaded In Memory Queue

A simple non-durable in memory queue for running background tasks using threads.

## Why

Projects like [Resque](https://github.com/resque/resque), [delayed job](https://github.com/collectiveidea/delayed_job), [queue classic](https://github.com/ryandotsmith/queue_classic), and [sidekiq](https://github.com/mperham/sidekiq) are great. They use data stores like postgres and redis to store information to be processed later. If you're prototyping a system or don't have access to a data store, you might still want to push off some work to a background process. If that's the case an in-memory threaded queue might be a good fit.

## Install

In your `Gemfile`:

```ruby
gem 'threaded_in_memory_queue'
```

Then run `$ bundle install`

## Use it

Add this code in an initializer to start the in memory queue worker (configuration options are below):

```ruby
ThreadedInMemoryQueue.start
```

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

Then to enqueue a task to be run in the background use `ThreadedInMemoryQueue.enqueue`:

```ruby
repo = Repo.last
ThreadedInMemoryQueue.enqueue(Archive, repo.last, 'staging')
```

The first argument is a class that defines the task to be processed and the rest of the arguments are passed to the task when it is run.

# Configure

The default number of worker threads is 16, you can configure that when you start your queue:

```ruby
ThreadedInMemoryQueue.start(size: 5)
```

By default jobs have a timeout value of 60 seconds. Since this is an in-memory queue (goes away when your process terminates) it is in your best interests to keep jobs small and quick, and not overload the queue. You can configure a different timeout on start:

```ruby
ThreadedInMemoryQueue.start(timeout: 90) # timeout is in seconds
```

Want a different logger? Specify a different Logger:

```ruby
ThreadedInMemoryQueue.start(logger: MyCustomLogger.new)
```

For testing or guaranteed code execution use the Inline option:

```ruby
ThreadedInMemoryQueue.inline = true
```

This option bypasses the queue and executes code as it comes.

## Thread Considerations

This worker operates in the same process as your app, that means if your app is CPU bound, it will not be very useful. This worker uses threads which means that to be useful your app needs to either use IO (database calls, file writes/reads, shelling out, etc.) or run on JRuby or Rubinius.

To make sure all items in your queue are processed you can add a condition `at_exit` to your program:

```ruby
at_exit do
  ThreadedInMemoryQueue.stop
end
```

This call takes an optional timeout value (in seconds), the default is 10.

## License

MIT

