# frozen_string_literal: true

require "zeitwerk"
require "active_support/notifications"
require "active_support/core_ext/hash/indifferent_access"
require "active_support/isolated_execution_state"

module Interceptors
  class << self
    def loader
      @loader ||= Zeitwerk::Loader.for_gem.tap do |loader|
        loader.inflector.inflect("version" => "VERSION")
      end
    end

    def configure
      yield configuration
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def instrument(event_name, payload)
      if block_given?
        ActiveSupport::Notifications.instrument(event_name, payload) { yield }
      else
        ActiveSupport::Notifications.instrument(event_name, payload)
      end
    end

    private

    def log_instrumentation_failure(exception, event_name, payload)
      message = "[Interceptors] instrumentation failure for #{event_name}: #{exception.class} - #{exception.message}"
      logger = configuration.logger
      if logger&.respond_to?(:error)
        logger.error(message)
      else
        Kernel.warn(message)
      end
      if logger&.respond_to?(:debug)
        logger.debug("payload=#{payload.inspect}")
      end
    end
  end

  class Configuration
    attr_accessor :notification_namespace, :logger

    def initialize
      @notification_namespace = "use_case"
      @logger = nil
    end
  end
end

Interceptors.loader.setup
