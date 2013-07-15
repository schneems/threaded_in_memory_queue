module ThreadedInMemoryQueue
  class NoWorkersError < RuntimeError; end

  class WorkerNotStarted < RuntimeError; end
end
