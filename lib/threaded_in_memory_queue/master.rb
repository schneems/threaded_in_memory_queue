module ThreadedInMemoryQueue
  class Master
    include ThreadedInMemoryQueue::Timeout
    attr_reader :workers, :logger

    DEFAULT_TIMEOUT = 60 # seconds, 1 minute
    DEFAULT_SIZE    = 16

    def initialize(options = {})
      @queue   = Queue.new
      @size    = options[:size]    || DEFAULT_SIZE
      @timeout = options[:timeout] || DEFAULT_TIMEOUT
      @logger  = options[:logger]  || ThreadedInMemoryQueue.logger
      @workers = []
    end

    def start
      return self if alive?
      @size.times { @workers << Worker.new(@queue, timeout: @timeout).start }
      return self
    end

    def join
      workers.each {|w| w.join }
      return self
    end

    def poison
      workers.each {|w| w.poison }
      return self
    end

    def stop(timeout = 10)
      poison
      timeout(timeout, "waiting for workers to stop") do
        while self.alive?
          sleep 0.1
        end
        self.join
      end
      return self
    end

    def enqueue(job, *json)
      raise NoWorkersError unless alive?
      @queue.enq([job, json])
      return true
    end

    def alive?
      return false if workers.empty?
      workers.detect {|w| w.alive? }
    end
  end
end



