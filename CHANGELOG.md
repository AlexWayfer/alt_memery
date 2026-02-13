# Changelog

## Unreleased

## 3.0.2 (2026-02-13)

*   Update `module_methods` runtime dependency.
*   Update `rubocop` development dependency.

## 3.0.1 (2026-02-01)

*   Return Ruby 3.2 and 3.3 support.

## 3.0.0 (2026-01-08)

*   Allow to memoize multiple method names.
*   Performance improvements.
*   Enshure that marshalizing works correctly.
*   Add specs for double memoization.
*   Add Ruby 3.4 and 4.0 support.
*   Drop Ruby 2.5, 2.6, 2.7, 3.0, 3.1, 3.2 and 3.3 support.
*   Improve README.
*   Actualize gem specs metadata.
*   Add `bundle-audit` CI task.
*   Improve Cirrus CI config.
*   Improve RuboCop config.
*   Resolve new RuboCop offenses.
*   Lock RuboCop version better.
*   Update development dependencies.

## 2.1.0 (2021-02-10)

*   Support Ruby 3.
*   Fix error of `#clear_memery_cache!` with specific methods and without existing cache.
*   Improve specs.
*   Update development dependencies.
*   Update documentation.

## 2.0.0 (2020-07-09)

*   Rename gem.
*   Rewrite implementation from `prepend Module` to `UnboundMethod`.
    See discussion here: <https://github.com/tycooon/memery/pull/1>.
*   Delete `Gemfile.lock` and lock dependencies versions in `gemspec`.
*   Update dependencies.
    Unmaintained `coveralls` replaced with `codecov`.
    `bundler` dependency dropped with `Rakefile`.
*   Replace `require` with `require_relative`.
*   Replace Umbrella styles with standard RuboCop.
*   Improve README.
*   Replace Travis CI with Cirrus CI.
    You can see discussion here: <https://github.com/tycooon/memery/issues/28>.
*   Add `remark` CI task for linting Markdown.
*   Delete `benchmark.rb`.
    You can find improving example here: <https://gist.github.com/AlexWayfer/37ebb8b9f3429650b86fb4cea7ae3693>.

### Unreleased Memery

*   Fix compatibility with `ActiveSupport::Concern`.

## 1.3.0 (2020-02-10)

*   Allow memoization after including module with Memery.
*   Make `memoize` return the method name to allow chaining.
*   Fix warnings in Ruby 2.7.

## 1.2.0 (2019-10-19)

*   Add `:ttl` option for `memoize` method.
*   Add benchmark script.
*   Add `.memoized?` method.

## 1.1.0 (2019-08-05)

*   Optimize speed and memory for cached values returns.

## 1.0.0 (2018-08-31)

*   Add `:condition` option for `.memoize` method.

## 0.6.0 (2018-04-20)

*   Add example of class methods memoization into README.
*   Memery raises `ArgumentError` if method is not defined when you call `memoize`.

## 0.5.0 (2017-06-12)

*   Initial public version.
