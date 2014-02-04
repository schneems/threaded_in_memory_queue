module Threaded
  module Timeout
    def timeout(timeout, message = "", &block)
      ::Timeout.timeout(timeout) do
        yield
      end
    rescue ::Timeout::Error
      logger.error("Took longer than #{timeout} to #{message.inspect}")
    end
  end
end