module AppReputation
  class ConcurrentRunner
    attr_reader :results
    
    def initialize(thread_count)
      @thread_count = thread_count
      @threads = Array.new(@thread_count).extend(MonitorMixin)
      @work_queue = SizedQueue.new(@thread_count)
      @threads_available = @threads.new_cond
      @sysexit = false
      @results = []
      @results_mutex = Mutex.new
    end
    
    class << self
      def set(thread_count = 8)
        new(thread_count)
      end
    end
    
    def set_producer_thread(jobs)
      @producer_thread = Thread.new do
        jobs.each do |job|
          @work_queue.push(job)
          @threads.synchronize do
            @threads_available.signal
          end
        end
        @sysexit = true
      end
    end
    
    def set_consumer_thread
      @consumer_thread = Thread.new do
        loop do
          break if @sysexit && @work_queue.empty?
          found_index = nil
          available_thread = -> (thread) { thread.nil? || !thread.status || !thread['finished'].nil? }
          @threads.synchronize do
            @threads_available.wait_while do
              @threads.select(&available_thread).empty?
            end
            found_index = @threads.rindex(&available_thread)
          end
          job = @work_queue.pop
          @threads[found_index] = Thread.new do
            @results_mutex.synchronize do
              @results.push(job.call)
            end
            Thread.current["finished"] = true
            @threads.synchronize do
              @threads_available.signal
            end
          end
        end
      end
    end
    
    def run
      if @producer_thread && @consumer_thread
        @producer_thread.join
        @consumer_thread.join
        @threads.each do |thread|
          thread.join unless thread.nil?
        end
      else
        raise 'No available producer thread or consumer thread, please set first'
      end
    end
    
    private_class_method :new
  end
end
