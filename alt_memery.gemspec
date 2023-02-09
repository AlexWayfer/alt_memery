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

  spec.license = 'MIT'

  github_uri = 'https://github.com/AlexWayfer/alt_memery'

  spec.homepage = github_uri

  spec.metadata = {
    'bug_tracker_uri' => "#{github_uri}/issues",
    'changelog_uri' => "#{github_uri}/blob/v#{spec.version}/CHANGELOG.md",
    'documentation_uri' => "http://www.rubydoc.info/gems/#{spec.name}/#{spec.version}",
    'homepage_uri' => spec.homepage,
    'rubygems_mfa_required' => 'true',
    'source_code_uri' => github_uri
  }

  spec.files         = Dir['lib/**/*.rb', 'README.md', 'LICENSE.txt', 'CHANGELOG.md']
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7', '< 4'

  spec.add_runtime_dependency 'module_methods', '~> 0.1.0'

  spec.add_development_dependency 'activesupport', '~> 7.0'
  spec.add_development_dependency 'pry-byebug', '~> 3.9'

  spec.add_development_dependency 'benchmark-ips', '~> 2.0'
  spec.add_development_dependency 'benchmark-memory', '~> 0.2.0'

  spec.add_development_dependency 'bundler-audit', '~> 0.9.0'

  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'simplecov', '~> 0.22.0'
  spec.add_development_dependency 'simplecov-cobertura', '~> 2.1'

  spec.add_development_dependency 'rubocop', '~> 1.45.1'
  spec.add_development_dependency 'rubocop-performance', '~> 1.5'
  spec.add_development_dependency 'rubocop-rspec', '~> 2.0'

  spec.add_development_dependency 'gem_toys', '~> 0.12.1'
  spec.add_development_dependency 'toys', '~> 0.14.2'
end
