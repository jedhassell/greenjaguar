module Greenjaguar
  class Retrier

    def initialize(policy, &block)
      @policy = policy
      @retry_block = block
      exec
    end

    private
    def exec
      @start_time = Time.new
      begin
        @retry_block.call
      rescue => e
        raise unless @policy.valid_exception? e
        if @policy.never_give_up?
          @policy.wait
          retry
        else
          if time_out? || retry_count_reached?
            raise unless @policy.fail_silently?
          else
            decrement_retry_count
            @policy.wait
            retry
          end
        end
      end
    end

    def time_out?
      Time.now - @start_time > @policy.timeout
    end

    def decrement_retry_count
      @policy.count -= 1
    end

    def retry_count_reached?
      @policy.count == 0
    end
  end
end
