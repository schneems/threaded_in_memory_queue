require 'test_helper'

class ThreadedInMemoryQueueTest < Test::Unit::TestCase

  def test_calls_contents_of_blocks
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    ThreadedInMemoryQueue.start

    job = Proc.new {|x| Dummy.process(x) }

    ThreadedInMemoryQueue.enqueue(job, 1)
    ThreadedInMemoryQueue.enqueue(job, 2)
    ThreadedInMemoryQueue.stop
  end

  def test_calls_contents_of_klasses
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    ThreadedInMemoryQueue.start

    job = Class.new do
      def self.call(num)
        Dummy.process(num)
      end
    end

    ThreadedInMemoryQueue.enqueue(job, 1)
    ThreadedInMemoryQueue.enqueue(job, 2)
    ThreadedInMemoryQueue.stop
  end

  def test_configure_size
    size = 1
    ThreadedInMemoryQueue.start(size: size)
    assert_equal size, ThreadedInMemoryQueue.master.workers.size
    ThreadedInMemoryQueue.stop

    size = 3
    ThreadedInMemoryQueue.start(size: size)
    assert_equal size, ThreadedInMemoryQueue.master.workers.size
    ThreadedInMemoryQueue.stop

    size = 6
    ThreadedInMemoryQueue.start(size: size)
    assert_equal size, ThreadedInMemoryQueue.master.workers.size
    ThreadedInMemoryQueue.stop

    size = 16
    ThreadedInMemoryQueue.start(size: size)
    assert_equal size, ThreadedInMemoryQueue.master.workers.size
    ThreadedInMemoryQueue.stop
  end
end
