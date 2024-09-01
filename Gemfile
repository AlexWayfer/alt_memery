# frozen_string_literal: true

source 'https://rubygems.org'

gemspec

group :development do
  gem 'activesupport', '~> 7.0'
  gem 'pry-byebug', '~> 3.9'

  gem 'gem_toys', '~> 0.13.0'
  gem 'toys', '~> 0.15.3'
end

group :test do
  gem 'rspec', '~> 3.0'
  gem 'simplecov', '~> 0.22.0'
  gem 'simplecov-cobertura', '~> 2.1'
end

group :lint do
  gem 'rubocop', '~> 1.66.0'
  gem 'rubocop-performance', '~> 1.5'
  gem 'rubocop-rspec', '~> 2.0'
end

group :benchmark do
  gem 'benchmark-ips', '~> 2.0'
  gem 'benchmark-memory', '~> 0.2.0'
end

group :audit do
  gem 'bundler-audit', '~> 0.9.0'
end
