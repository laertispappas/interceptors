# frozen_string_literal: true

module Interceptors
  module UseCaseMixin
    def self.included(base)
      base.include(UseCaseCore)
    end
  end
end
