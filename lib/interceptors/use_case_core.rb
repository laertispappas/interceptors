# frozen_string_literal: true

module Interceptors
  module UseCaseCore
    def self.included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
      base.instance_variable_set(:@interceptors, [])
    end

    module ClassMethods
      def interceptors
        @interceptors ||= []
      end

      def use(interceptor)
        interceptors << interceptor
        self
      end

      def call(input = {}, **kwargs)
        new.call(input, **kwargs)
      end

      def inherited(subclass)
        super
        subclass.instance_variable_set(:@interceptors, interceptors.dup)
      end
    end

    module InstanceMethods
      def call(input = {}, **kwargs)
        ctx = build_context(input, **kwargs)

        instrument(event_name("start"), name: self.class.name, ctx: ctx)

        result = pipeline.call(ctx) { |context| normalize_result(execute(context)) }
        result = normalize_result(result)

        instrument(event_name("finish"),
                   name: self.class.name,
                   ctx: ctx,
                   ok: result.ok?,
                   error: result.error&.message)

        result
      rescue AppError => e
        instrument(event_name("error"),
                   name: self.class.name,
                   ctx: ctx,
                   code: e.code,
                   message: e.message)

        Result.err(e, meta: base_meta)
      rescue StandardError => e
        instrument(event_name("error"),
                   name: self.class.name,
                   ctx: ctx,
                   code: "unhandled_exception",
                   message: e.message,
                   error_class: e.class.name)

        err = AppError.new("Unhandled exception",
                           code: "unhandled_exception",
                           http_status: 500,
                           details: { cause: e.class.name })
        Result.err(err, meta: base_meta.merge(error_class: e.class.name))
      end

      private

      def execute(_ctx)
        raise NotImplementedError, "#{self.class} must implement #execute"
      end

      def default_context
        {}
      end

      def normalize_result(result)
        case result
        when Result
          result
        when nil
          Result.ok
        else
          Result.ok(result)
        end
      end

      def base_meta
        { use_case: self.class.name }
      end

      def build_context(input, **kwargs)
        ctx = default_context.merge(normalize_input(input))
        ctx.merge!(kwargs) unless kwargs.empty?
        ctx.with_indifferent_access
      end

      def normalize_input(input)
        return input if input.is_a?(Hash)
        return input.to_h if input.respond_to?(:to_h)

        raise ArgumentError, "use case input must be a Hash or respond to #to_h (got #{input.class})"
      end

      def pipeline
        Pipeline.new(self.class.interceptors)
      end

      def notification_namespace
        Interceptors.configuration.notification_namespace
      end

      def instrument(event_name, payload, &block)
        Interceptors.instrument(event_name, payload, &block)
      end

      def event_name(suffix)
        "#{notification_namespace}.#{suffix}"
      end
    end
  end
end
