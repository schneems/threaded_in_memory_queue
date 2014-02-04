require 'test_helper'

class ThreadedTest < Test::Unit::TestCase

  def test_started?
    Threaded.start
    assert Threaded.started?
    Threaded.stop
    sleep 1
    assert Threaded.stopped?
    refute Threaded.started?
  end

  def test_inline
    Dummy.expects(:process).with(1).once
    job = Proc.new {|x| Dummy.process(x) }

    Threaded.inline = true
    Threaded.enqueue(job, 1)
    assert Threaded.inline
    assert Threaded.stopped?
  ensure
    Threaded.inline = false
  end

  def test_enqueues
    Dummy.expects(:process).with(1).once
    Dummy.expects(:process).with(2).once

    Threaded.start

    job = Proc.new {|x| Dummy.process(x) }

    Threaded.enqueue(job, 1)
    Threaded.enqueue(job, 2)
  ensure
    Threaded.stop
  end

end
