require 'test_helper'

class ThreadedInMemoryQueueTest < Test::Unit::TestCase

  def test_started?
    ThreadedInMemoryQueue.start
    assert ThreadedInMemoryQueue.started?
    ThreadedInMemoryQueue.stop
    sleep 1
    assert ThreadedInMemoryQueue.stopped?
    refute ThreadedInMemoryQueue.started?
  end

  def test_inline
    Dummy.expects(:process).with(1).once
    job = Proc.new {|x| Dummy.process(x) }

    ThreadedInMemoryQueue.inline = true
    ThreadedInMemoryQueue.enqueue(job, 1)
    assert ThreadedInMemoryQueue.inline
    assert ThreadedInMemoryQueue.stopped?
  ensure
    ThreadedInMemoryQueue.inline = false
  end

  def test_enqueues
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    ThreadedInMemoryQueue.start

    job = Proc.new {|x| Dummy.process(x) }

    ThreadedInMemoryQueue.enqueue(job, 1)
    ThreadedInMemoryQueue.enqueue(job, 2)
  ensure
    ThreadedInMemoryQueue.stop
  end

end
