# frozen_string_literal: true

module Interceptors
  class LoggingInterceptor < Interceptor
    def initialize(logger: nil)
      @logger = logger
    end

    def before(ctx)
      log(:before, ctx: ctx)
    end

    def after(_ctx, result)
      log(:after, ok: result.ok?, error: result.error&.message)
      result
    end

    private

    def log(stage, payload)
      event = event_name("log")
      Interceptors.instrument(event, payload.merge(stage: stage))
      return unless @logger

      @logger.info("[Interceptors] stage=#{stage} payload=#{payload}")
    end

    def event_name(suffix)
      "#{Interceptors.configuration.notification_namespace}.#{suffix}"
    end
  end
end
