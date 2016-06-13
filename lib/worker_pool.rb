require 'thread'

class WorkerPool
  WAIT_TIMEOUT = 1000 # 1 second

  def initialize workers
    @interrupted = false

    # signal handling
    Signal.trap('INT') do
      @interrupted = true
      finish

      exit 0
    end

    @tasks = Queue.new
    @workers = (0...workers).map do |i|
      Thread.new do |t|
        begin
          loop do
            wait_for_tasks

            if @tasks.empty? or @interrupted
              break
            end

            x = @tasks.pop(true)
            x.call
          end
        rescue => e
          puts e.inspect
        end
      end
    end
  end

  def <<(&block)
    @tasks.push block
  end

  def finish
    @workers.map(&:join)
  end

private

  def wait_for_tasks
    start_time = Time.now

    while @tasks.length == 0 do
      # wait for tasks to arrive, break if WAIT_TIMEOUT has been reached
      if Time.now - start_time >= WAIT_TIMEOUT / 1000.0
        break
      end
    end
  end
end
