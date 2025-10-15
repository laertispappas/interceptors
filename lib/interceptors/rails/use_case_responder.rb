# frozen_string_literal: true

module Interceptors
  module Rails
    module UseCaseResponder
      private

      def respond_with_use_case(result, serializer: nil, status_ok: 200, **render_options)
        if result.ok?
          body = serializer ? serializer.new(result.value) : result.value
          render({ json: body, status: status_ok }.merge(render_options))
        else
          error = result.error
          payload = {
            error: error.code,
            message: error.message,
            details: error.details
          }
          render({ json: payload, status: error.http_status }.merge(render_options))
        end
      end
    end
  end
end
