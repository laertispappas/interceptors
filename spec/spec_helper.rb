require "bundler/setup"
require "rspec"
require "active_support/notifications"

require_relative "../lib/interceptors"

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before do
    Interceptors.configure do |settings|
      settings.notification_namespace = "use_case"
    end

    Interceptors::IdempotencyInterceptor::DEFAULT_STORE.clear
  end
end
