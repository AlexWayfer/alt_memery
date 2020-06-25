# frozen_string_literal: true

require_relative 'lib/memery/version'

Gem::Specification.new do |spec|
  spec.name          = 'alt_memery'
  spec.version       = Memery::VERSION
  spec.authors       = ['Yuri Smirnov', 'Alexander Popov']
  spec.email         = ['alex.wayfer@gmail.com']

  spec.summary       = 'A gem for memoization.'
  spec.description   = <<~TEXT
    Alt Memery is a gem for memoization.
    It's a fork of Memery with implementation via `UnboundMethod` instead of `prepend Module`.
  TEXT
  spec.homepage      = 'https://github.com/AlexWayfer/alt_memery'
  spec.license       = 'MIT'

  spec.files         = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'ruby2_keywords', '~> 0.0.2'

  spec.add_development_dependency 'activesupport', '~> 6.0'
  spec.add_development_dependency 'benchmark-ips', '~> 2.0'
  spec.add_development_dependency 'benchmark-memory', '~> 0.1.0'
  spec.add_development_dependency 'codecov', '~> 0.1.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.86.0'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 1.38'
  spec.add_development_dependency 'simplecov', '~> 0.18.0'
end
