# frozen_string_literal: true

require "memery/version"

module Memery
  class << self
    def included(base)
      base.extend(ClassMethods)
      base.include(InstanceMethods)
    end

    def method_visibility(klass, method_name)
      case
      when klass.private_method_defined?(method_name)
        :private
      when klass.protected_method_defined?(method_name)
        :protected
      when klass.public_method_defined?(method_name)
        :public
      end
    end

    def monotonic_clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end
  end

  module ClassMethods
    def memoized_methods
      @memoized_methods ||= {}
    end

    def memoize(method_name, condition: nil, ttl: nil)
      visibility = Memery.method_visibility(self, method_name)
      memoized_methods[method_name] =
        original_method = instance_method(method_name)

      remove_method method_name

      define_method(method_name) do |*args, &block|
        if block || (condition && !instance_exec(&condition))
          return original_method.bind(self).call(*args, &block)
        end

        key = "#{method_name}_#{original_method.object_id}"

        store = (@_memery_memoized_values ||= {})[key] ||= {}

        if store.key?(args) && (ttl.nil? || Memery.monotonic_clock <= store[args][:time] + ttl)
          return store[args][:result]
        end

        result = original_method.bind(self).call(*args)
        @_memery_memoized_values[key][args] = { result: result, time: Memery.monotonic_clock }
        result
      end

      send(visibility, method_name)
    end

    def memoized?(method_name)
      memoized_methods.key?(method_name)
    end
  end

  module InstanceMethods
    def clear_memery_cache!
      @_memery_memoized_values = {}
    end
  end
end
