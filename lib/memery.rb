# frozen_string_literal: true

require 'module_methods'
require 'ruby2_keywords'

require_relative 'memery/version'

## Module for memoization
module Memery
  extend ::ModuleMethods::Extension

  class << self
    def monotonic_clock
      Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def method_visibility(klass, method_name)
      if klass.private_method_defined?(method_name)
        :private
      elsif klass.protected_method_defined?(method_name)
        :protected
      elsif klass.public_method_defined?(method_name)
        :public
      else
        raise ArgumentError, "Method #{method_name} is not defined on #{klass}"
      end
    end
  end

  ## Module for class methods
  module ClassMethods
    def memoized_methods
      @memoized_methods ||= {}
    end

    def memoize(method_name, condition: nil, ttl: nil)
      original_visibility = Memery.method_visibility(self, method_name)

      memoized_methods[method_name] = instance_method(method_name)

      undef_method method_name

      define_memoized_method method_name, condition: condition, ttl: ttl

      ruby2_keywords method_name

      send original_visibility, method_name

      method_name
    end

    def memoized?(method_name)
      memoized_methods.key?(method_name)
    end

    private

    def define_memoized_method(method_name, condition:, ttl:)
      original_method = memoized_methods[method_name]

      define_method method_name do |*args, &block|
        if block || (condition && !instance_exec(&condition))
          return original_method.bind(self).call(*args, &block)
        end

        store = memery_store method_name

        return store[args][:result] if memoized_result_actual?(store, args, ttl: ttl)

        call_original_and_memoize original_method, args, store
      end
    end
  end

  def clear_memery_cache!(*method_names)
    return unless defined? @_memery_memoized_values

    if method_names.any?
      method_names.each { |method_name| @_memery_memoized_values[method_name]&.clear }
    else
      @_memery_memoized_values.clear
    end
  end

  private

  def memery_store(method_name)
    ((@_memery_memoized_values ||= {})[method_name] ||= {})[self.class] ||= {}
  end

  def memoized_result_actual?(store, args, ttl:)
    store.key?(args) && (ttl.nil? || Memery.monotonic_clock <= store[args][:time] + ttl)
  end

  def call_original_and_memoize(original_method, args, store)
    result = original_method.bind(self).call(*args)
    store[args] = { result: result, time: Memery.monotonic_clock }
    result
  end
end
