# frozen_string_literal: true

module Interceptors
  class Base
    def on_enter(ctx)
      ctx
    end

    def on_leave(ctx)
      ctx
    end

    def on_error(ctx)
      ctx
    end
  end
end
