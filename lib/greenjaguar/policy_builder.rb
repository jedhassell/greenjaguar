module Greenjaguar
  class PolicyBuilder
    attr_accessor :count, :wait_strategy, :timeout, :logger, :exceptions

    def initialize(&block)
      @count = 1
      @timeout = 300
      @exceptions = []
      instance_eval(&block)
    end

    def times(retry_count)
      @count = retry_count
      self
    end

    def timeout_after(retry_timeout)
      @timeout = retry_timeout
      self
    end

    def logger(logger)
      @logger = logger
      self
    end

    def fail_silently
      @fail_silently = true
    end

    def fail_silently?
      @fail_silently
    end

    def never_give_up
      @count = -1
    end

    def never_give_up?
      @count == -1
    end

    def measure_time_in(time_unit)
      strategy.time_unit = time_unit
      self
    end

    def with_strategy(wait_strategy, *args)
      @strategy = init_wait_strategy(wait_strategy, *args)
      self
    end

    def only_on_exceptions(exception_array)
      @exceptions.concat exception_array
    end

    def valid_exception?(exception)
      if @exceptions.empty?
        return true
      else
        @exceptions.each {|ex| return true if exception.class <= ex}
      end
      false
    end

    def wait
      strategy.wait
    end

    def strategy
      @strategy ||= init_wait_strategy(:default)
    end

    private

    def init_wait_strategy(wait_strategy, *args)
      case wait_strategy
        when :fibonacci
          return Greenjaguar::Strategies::FibonacciStrategy.new
        when :exponential_backoff
          return Greenjaguar::Strategies::ExponentialBackoffStrategy.new
        when :random
          return Greenjaguar::Strategies::RandomStrategy.new
        when :fixed_interval
          return Greenjaguar::Strategies::FixedIntervalStrategy.new(*args)
        else
          return Greenjaguar::Strategies::DefaultWaitStrategy.new
      end
    end
  end
end