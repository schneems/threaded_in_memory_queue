module Threaded
  class Master
    include Threaded::Timeout
    attr_reader :workers, :logger

    DEFAULT_TIMEOUT = 60 # seconds, 1 minute
    DEFAULT_SIZE    = 16

    def initialize(options = {})
      @queue    = Queue.new
      @mutex    = Mutex.new
      @stopping = false
      @max      = options[:size]     || DEFAULT_SIZE
      @timeout  = options[:timeout]  || DEFAULT_TIMEOUT
      @logger   = options[:logger]   || Threaded.logger
      @workers  = []
    end

    def enqueue(job, *json)
      @queue.enq([job, json])

      new_worker if needs_workers? && @queue.size > 0
      raise NoWorkersError unless alive?
      return true
    end

    def alive?
      return false if workers.empty?
      workers.detect {|w| w.alive? }
    end

    def start
      return self if alive?
      @max.times { new_worker }
      return self
    end

    def stop(timeout = 10)
      poison
      timeout(timeout, "waiting for workers to stop") do
        while self.alive?
          sleep 0.1
        end
        join
      end
      return self
    end

    def size
      @workers.size
    end

    private

    def needs_workers?
      size < @max
    end

    def new_worker
      @mutex.synchronize do
        return false unless needs_workers?
        return false if @stopping
        @workers << Worker.new(@queue, timeout: @timeout)
      end
    end

    def join
      workers.each {|w| w.join }
      return self
    end

    def poison
      @mutex.synchronize do
        @stopping = true
      end
      workers.each {|w| w.poison }
      return self
    end
  end
end
