module ThreadedInMemoryQueue
  class Worker
    DEFAULT_TIMEOUT = 60 # seconds, 1 minute
    POISON          = "poison"
    include ThreadedInMemoryQueue::Timeout
    attr_reader :queue, :logger

    def initialize(queue, options = {})
      @queue   = queue
      @timeout = options[:timeout] || DEFAULT_TIMEOUT
      @logger  = options[:logger]  || ThreadedInMemoryQueue.logger
    end

    def thread
      raise WorkerNotStarted, "Must start worker before using" unless @thread
      @thread
    end

    def start
      @thread ||= create_thread
      return self
    end

    def poison(times = 1)
      @queue.enq(POISON)
    end

    def alive?
      return false unless @thread
      thread.alive?
    end

    def join
      return false unless @thread
      thread.join
    end

    private
    def create_thread
      Thread.new {
        logger.info("Worker #{object_id} ready")
        loop do
          payload   = queue.pop
          job, json = *payload
          break if payload == POISON

          self.timeout(@timeout, "job: #{job.to_s}") do
            job.call(*json)
          end
        end
        logger.info("Worker #{object_id} stopped")
      }
    end
  end
end
