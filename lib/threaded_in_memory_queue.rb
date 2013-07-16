require 'thread'
require 'timeout'
require 'logger'

require 'threaded_in_memory_queue/version'
require 'threaded_in_memory_queue/inline'
require 'threaded_in_memory_queue/timeout'

module ThreadedInMemoryQueue
  extend Inline

  class << self
    attr_accessor :logger
  end

  def self.start(options = {})
    self.logger = options[:logger] if options[:logger]
    self.master = Master.new(options).start
    return self
  end

  def self.master
    Thread.current[:threaded_in_memory_queue_master]
  end

  def self.master=(master)
    Thread.current[:threaded_in_memory_queue_master] = master
  end

  def self.enqueue(klass, *args)
    raise NoWorkersError, "must start worker before enqueueing jobs" unless master
    master.enqueue(klass, *args)
    return true
  end

  def self.stop(timeout = 10)
    master.stop(timeout) if master
    return true
  end
end

ThreadedInMemoryQueue.logger = Logger.new(STDOUT)
ThreadedInMemoryQueue.logger.level = Logger::INFO


require 'threaded_in_memory_queue/errors'
require 'threaded_in_memory_queue/worker'
require 'threaded_in_memory_queue/master'
