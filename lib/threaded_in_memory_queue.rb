require 'thread'
require 'timeout'
require 'logger'

require 'threaded_in_memory_queue/version'
require 'threaded_in_memory_queue/timeout'

module ThreadedInMemoryQueue
  STOP_TIMEOUT = 10 # seconds
  extend self
  attr_accessor :inline, :logger, :size, :timeout
  alias :inline? :inline

  def start(options = {})
    self.logger  = options[:logger]  if options[:logger]
    self.size    = options[:size]    if options[:size]
    self.timeout = options[:timeout] if options[:timeout]
    self.master  = Master.new(logger:  self.logger,
                              size:    self.size,
                              timeout: self.timeout)
    self.master.start
    return self
  end

  def configure(&block)
    raise "Queue is already started, must configure queue before starting" if started?
    yield self
  end
  alias :config  :configure

  def started?
    return false unless master
    master.alive?
  end

  def stopped?
    !started?
  end

  def master
    @master
  end

  def master=(master)
    @master = master
  end

  def enqueue(job, *args)
    if inline?
      job.call(*args)
    else
      raise NoWorkersError unless started?
      master.enqueue(job, *args)
    end
    return true
  end

  def stop(timeout = STOP_TIMEOUT)
    return true unless master
    master.stop(timeout)
    return true
  end
end

ThreadedInMemoryQueue.logger       = Logger.new(STDOUT)
ThreadedInMemoryQueue.logger.level = Logger::INFO


require 'threaded_in_memory_queue/errors'
require 'threaded_in_memory_queue/worker'
require 'threaded_in_memory_queue/master'
