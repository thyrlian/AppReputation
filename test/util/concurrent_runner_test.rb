require_relative '../test_helper'

class ConcurrentRunnerTest < Minitest::Test
  def setup
    @concurrent_runner = AppReputation::ConcurrentRunner.set
    @default_thread_count = 8
  end
  
  def assert_initialization_state(concurrent_runner, thread_count)
    threads = concurrent_runner.instance_variable_get(:@threads)
    work_queue = concurrent_runner.instance_variable_get(:@work_queue)
    threads_available = concurrent_runner.instance_variable_get(:@threads_available)
    queue = SizedQueue.new(thread_count)
    assert_equal(thread_count, concurrent_runner.instance_variable_get(:@thread_count))
    assert_equal(Array.new(thread_count), threads)
    assert_equal(thread_count, work_queue.max)
    assert_equal(queue.instance_variable_get(:@que), work_queue.instance_variable_get(:@que))
    assert_equal(Array.new(thread_count), threads_available.instance_variable_get(:@monitor))
    refute(concurrent_runner.instance_variable_get(:@sysexit))
    assert_equal([], concurrent_runner.results)
  end
  
  def test_set_with_arg
    thread_count = 4
    concurrent_runner = AppReputation::ConcurrentRunner.set(thread_count)
    assert_initialization_state(concurrent_runner, thread_count)
    assert_nil(concurrent_runner.instance_variable_get(:@producer_thread))
    assert_nil(concurrent_runner.instance_variable_get(:@consumer_thread))
  end
  
  def test_set_without_arg
    assert_initialization_state(@concurrent_runner, @default_thread_count)
    assert_nil(@concurrent_runner.instance_variable_get(:@producer_thread))
    assert_nil(@concurrent_runner.instance_variable_get(:@consumer_thread))
  end
  
  def test_set_producer_thread
    jobs = [MiniTest::Mock.new, MiniTest::Mock.new, MiniTest::Mock.new]
    @concurrent_runner.set_producer_thread(jobs)
    assert_initialization_state(@concurrent_runner, @default_thread_count)
    assert_nil(@concurrent_runner.instance_variable_get(:@consumer_thread))
    refute_nil(@concurrent_runner.instance_variable_get(:@producer_thread))
  end
  
  def test_set_consumer_thread
    @concurrent_runner.set_consumer_thread
    assert_initialization_state(@concurrent_runner, @default_thread_count)
    assert_nil(@concurrent_runner.instance_variable_get(:@producer_thread))
    refute_nil(@concurrent_runner.instance_variable_get(:@consumer_thread))
  end
  
  def test_run_without_any_thread
    assert_raises RuntimeError do
      @concurrent_runner.run
    end
  end
  
  def test_run_without_producer_thread
    @concurrent_runner.set_consumer_thread
    assert_raises RuntimeError do
      @concurrent_runner.run
    end
  end
  
  def test_run_without_consumer_thread
    jobs = [MiniTest::Mock.new]
    @concurrent_runner.set_producer_thread(jobs)
    assert_raises RuntimeError do
      @concurrent_runner.run
    end
  end
  
  def test_run
    jobs = []
    mock_proc_a = MiniTest::Mock.new.expect(:call, 2)
    mock_proc_b = MiniTest::Mock.new.expect(:call, 4)
    mock_proc_c = MiniTest::Mock.new.expect(:call, 6)
    mock_proc_d = MiniTest::Mock.new.expect(:call, 1)
    mock_proc_e = MiniTest::Mock.new.expect(:call, 3)
    mock_proc_f = MiniTest::Mock.new.expect(:call, 5)
    mock_proc_g = MiniTest::Mock.new.expect(:call, 0)
    jobs.push(mock_proc_a, mock_proc_b, mock_proc_c, mock_proc_d, mock_proc_e, mock_proc_f, mock_proc_g)
    
    @concurrent_runner.set_producer_thread(jobs)
    @concurrent_runner.set_consumer_thread
    @concurrent_runner.run
    
    assert(@concurrent_runner.instance_variable_get(:@sysexit))
    assert_equal([0, 1, 2, 3, 4, 5, 6], @concurrent_runner.results.sort)
    jobs.each { |job| job.verify }
  end
end
