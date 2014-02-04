module Threaded
  class Worker
    DEFAULT_TIMEOUT = 60 # seconds, 1 minute
    POISON          = "poison"
    include Threaded::Timeout
    attr_reader :queue, :logger, :thread

    def initialize(queue, options = {})
      @queue   = queue
      @timeout = options[:timeout] || DEFAULT_TIMEOUT
      @logger  = options[:logger]  || Threaded.logger
      @thread  = create_thread
    end

    def poison
      @queue.enq(POISON)
    end

    def start
      puts "start is deprecated, thread is started when worker created"
    end

    def alive?
      thread.alive?
    end

    def join
      thread.join
    end

    private
    def create_thread
      Thread.new {
        logger.info("Threaded In Memory Queue Worker '#{object_id}' ready")
        loop do
          payload   = queue.pop
          job, json = *payload
          break if payload == POISON

          self.timeout(@timeout, "job: #{job.to_s}") do
            job.call(*json)
          end
        end
        logger.info("Threaded In Memory Queue Worker '#{object_id}' stopped")
      }
    end
  end
end
