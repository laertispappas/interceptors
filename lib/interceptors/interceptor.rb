# frozen_string_literal: true

module Interceptors
  class Interceptor
    def before(_ctx); end

    def after(_ctx, result); result; end

    def around(ctx)
      yield ctx
    end
  end
end
