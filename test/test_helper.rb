Bundler.require

require 'threaded_in_memory_queue'
require 'test/unit'
require "mocha/setup"


module Dummy
end

ThreadedInMemoryQueue.logger.level = Logger::WARN