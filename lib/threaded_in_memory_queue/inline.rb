module ThreadedInMemoryQueue
  module Inline
    def inline
      Thread.current[:threaded_worker_inline]
    end

    def inline?
      inline
    end

    def inline=(inline)
      Thread.current[:threaded_worker_inline] = inline
    end
  end
end