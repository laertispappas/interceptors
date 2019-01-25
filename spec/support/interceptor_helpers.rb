module InterceptorsHelper
  class Base < Interceptors::Base
    attr_reader :factory

    def initialize(factory = "dummy")
      @factory = factory
    end

    def enter(context)
      context[factory] ||= {}
      context[factory][:on_enter] ||= 0
      context[factory][:on_enter] += 1
    end

    def leave(context)
      context[factory] ||= {}
      context[factory][:on_leave] ||= 0
      context[factory][:on_leave] += 1
    end

    def error(context)
      context[factory] ||= {}
      context[factory][:on_error] ||= 0
      context[factory][:on_error] += 1
    end
  end

  class TestEnter < Base
    def on_enter(context)
      enter(context)
    end
  end

  class TestLeave < Base
    def on_leave(context)
      leave(context)
    end
  end

  class TestEnterLeave < Base
    def on_enter(context)
      enter(context)
    end

    def on_leave(context)
      leave(context)
    end
  end

  class TestEnterError < Base
    def on_enter(context)
      enter(context)
    end

    def on_error(context)
      error(context)
    end
  end

  class TestEnterLeaveRaiseError < TestEnterLeave
    def on_leave(context)
      raise StandardError
    end
  end

  class TestEnterLeaveError < Base
    def on_enter(context)
      enter(context)
    end

    def on_leave(context)
      leave(context)
    end

    def on_error(context)
      error(context)
    end
  end

  class TestEnterRaiseException < Base
    def on_enter(context)
      raise StandardError
    end
  end

  class TestEnterErrorRaiseException < Base
    def on_enter(context)
      raise StandardError
    end

    def on_error(context)
      error(context)
    end
  end

  class TestEnterLeaveErrorResolve < TestEnterLeaveError
    def on_error(context)
      context[:error] = nil
      error(context)
    end
  end
end
