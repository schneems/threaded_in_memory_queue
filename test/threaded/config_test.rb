require 'test_helper'
require 'stringio'

class ConfigTest < Test::Unit::TestCase

  def teardown
    Threaded.stop
  end

  def test_config_works
    fake_out = StringIO.new
    logger   = Logger.new(fake_out)
    size     = rand(1..99)
    timeout  = rand(1..99)

    Threaded.configure do |config|
      config.size    = size
      config.logger  = logger
      config.timeout = timeout
    end

    Threaded.start

    assert_equal Threaded.size, size
    assert_equal Threaded.master.instance_variable_get("@size"), size

    assert_equal Threaded.timeout, timeout
    assert_equal Threaded.master.instance_variable_get("@timeout"), timeout

    assert_equal Threaded.logger, logger
    assert_equal Threaded.master.instance_variable_get("@logger"), logger
  end

  def test_config_cannot_call_after_start
    Threaded.start
    assert_raise(RuntimeError) do
      Threaded.configure do |config|
        config.size    = size
        config.logger  = logger
        config.timeout = timeout
      end
    end
  end

end
