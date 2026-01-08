# frozen_string_literal: true

## https://github.com/deivid-rodriguez/pry-byebug/issues/460
require 'pry-byebug'

require 'simplecov'

if ENV['CI']
  require 'simplecov-cobertura'
  SimpleCov.formatter = SimpleCov::Formatter::CoberturaFormatter
end

SimpleCov.start

require_relative '../lib/memery'
require 'active_support/concern'
