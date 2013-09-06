module ThreadedInMemoryQueue
  module Inline
    def inline
      @inline
    end

    def inline?
      inline
    end

    def inline=(inline)
      @inline = inline
    end
  end
end
