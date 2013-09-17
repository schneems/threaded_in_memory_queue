require 'test_helper'
require 'stringio'

class ConfigTest < Test::Unit::TestCase

  def teardown
    ThreadedInMemoryQueue.stop
  end

  def test_config_works
    fake_out = StringIO.new
    logger   = Logger.new(fake_out)
    size     = rand(1..99)
    timeout  = rand(1..99)

    ThreadedInMemoryQueue.configure do |config|
      config.size    = size
      config.logger  = logger
      config.timeout = timeout
    end

    ThreadedInMemoryQueue.start

    assert_equal ThreadedInMemoryQueue.size, size
    assert_equal ThreadedInMemoryQueue.master.instance_variable_get("@size"), size

    assert_equal ThreadedInMemoryQueue.timeout, timeout
    assert_equal ThreadedInMemoryQueue.master.instance_variable_get("@timeout"), timeout

    assert_equal ThreadedInMemoryQueue.logger, logger
    assert_equal ThreadedInMemoryQueue.master.instance_variable_get("@logger"), logger
  end

  def test_config_cannot_call_after_start
    ThreadedInMemoryQueue.start
    assert_raise(RuntimeError) do
      ThreadedInMemoryQueue.configure do |config|
        config.size    = size
        config.logger  = logger
        config.timeout = timeout
      end
    end
  end

end
