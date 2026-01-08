# Alt Memery

[![Cirrus CI - Base Branch Build Status](https://img.shields.io/cirrus/github/AlexWayfer/alt_memery?style=flat-square)](https://cirrus-ci.com/github/AlexWayfer/alt_memery)
[![Codecov branch](https://img.shields.io/codecov/c/github/AlexWayfer/alt_memery/main.svg?style=flat-square)](https://codecov.io/gh/AlexWayfer/alt_memery)
[![Code Climate](https://img.shields.io/codeclimate/maintainability/AlexWayfer/alt_memery.svg?style=flat-square)](https://codeclimate.com/github/AlexWayfer/alt_memery)
[![Depfu](https://img.shields.io/depfu/AlexWayfer/benchmark_toys?style=flat-square)](https://depfu.com/repos/github/AlexWayfer/alt_memery)
[![Inline docs](https://inch-ci.org/github/AlexWayfer/alt_memery.svg?branch=main)](https://inch-ci.org/github/AlexWayfer/alt_memery)
[![license](https://img.shields.io/github/license/AlexWayfer/alt_memery.svg?style=flat-square)](https://github.com/AlexWayfer/alt_memery/blob/main/LICENSE.txt)
[![Gem](https://img.shields.io/gem/v/alt_memery.svg?style=flat-square)](https://rubygems.org/gems/alt_memery)

Alt Memery allows to memoize methods return values.

The native simplest memoization in Ruby looks like this:

```ruby
def user
  @user ||= User.find(some_id)
end
```

But if you want to memoize falsy values — you have to use `defined?` instead of `||=`:

```ruby
def user
  return @user if defined?(@user)

  @user = User.find(some_id)
end
```

Even worse: if your calculations require multiple lines, you have to use `begin`/`end` block:

```ruby
def user
  @user ||= begin
    some_id = calculate_id
    klass = calculate_klass
    klass.find(some_id)
  end
end
```

And there is no elegant escape if your methods accept arguments.

But with memoization gems, like this one, you can simplify your code:

```ruby
memoize def user
  User.find(some_id)
end
```

Also, you're getting additional features, like conditions of memoization, time-to-live,
handy memoized values flushing, etc.

## Alt?

It's a fork of [Memery gem](https://github.com/tycooon/memery).
Original Memery uses `prepend Module.new` with memoized methods, not touching original ones.
This approach has advantages, but also has problems, see discussion here:
<https://github.com/tycooon/memery/pull/1>

So, this fork uses `UnboundMethod` as I've suggested in the PR above.

## Difference with other gems

### Memoizaion method and ancestors

Such gems like [Memoist](https://github.com/matthewrudy/memoist) override methods.
So, if you want to memoize a method in a child class with the same named memoized method
in a parent class — you have to use something like awkward `identifier: ` argument.
This gem allows you to just memoize methods when you want to.

Note how both method's return values are cached separately and don't interfere with each other.

### Memoized method arguments and clearing cache

This gem doesn't change method's arguments (no extra param like `reload`).
If you need to get unmemoize result of method — just call the `#clear_memery_cache!` method
with needed memoized method names:

```ruby
a.clear_memery_cache! :foo, :bar
```

Without arguments, `#clear_memery_cache!` will clear the whole instance's cache.

### Marshal compatibility

This gem doesn't require any global options, it works well with marshalized objects
in different proccesses with hashed arguments without performance impact.

## Installation

Add `gem 'alt_memery'` to your Gemfile.

## Usage

### Requirement

Since it's a fork of `memery` gem, require with:

```ruby
require 'memery'
```

Or from the `Gemfile`:

```ruby
gem 'alt_memery', require: 'memery'
```

### Code

```ruby
class A
  include Memery

  memoize def call
    puts "calculating"
    42
  end

  # Alternatively:
  # def call
  #   ...
  # end
  # memoize :call
end

a = A.new
a.call # => 42
a.call # => 42
a.call # => 42
# "calculating" will only be printed once.

a.call { 1 } # => 42
# "calculating" will be printed again because passing a block disables memoization.
```

Methods with arguments are supported and the memoization will be done based on arguments
using an internal hash. So this will work as expected:

```ruby
class A
  include Memery

  memoize def call(arg1, arg2)
    puts "calculating"
    arg1 + arg2
  end
end

a = A.new
a.call(1, 5) # => 6
a.call(2, 15) # => 17
a.call(1, 5) # => 6
# "calculating" will be printed twice, once for each unique argument list.
```

For class methods:

```ruby
class B
  class << self
    include Memery

    memoize def call
      puts "calculating"
      42
    end
  end
end

B.call # => 42
B.call # => 42
B.call # => 42
# "calculating" will only be printed once.
```

### Conditional Memoization

```ruby
class A
  include Memery

  attr_accessor :environment

  def call
    puts "calculating"
    42
  end

  memoize :call, condition: -> { environment == 'production' }
end

a = A.new
a.environment = 'development'
a.call # => 42
# calculating
a.call # => 42
# calculating
a.call # => 42
# calculating
# Text will be printed every time because result of condition block is `false`.

a.environment = 'production'
a.call # => 42
# calculating
a.call # => 42
a.call # => 42
# Text will be printed only once because there is memoization
# with `true` result of condition block.
```

### Memoization with Time-to-Live (TTL)

```ruby
class A
  include Memery

  def call
    puts "calculating"
    42
  end

  memoize :call, ttl: 3 # seconds
end

a = A.new
a.call # => 42
# calculating
a.call # => 42
a.call # => 42
# Text will be printed again only after 3 seconds of time-to-live.
# 3 seconds later...
a.call # => 42
# calculating
a.call # => 42
a.call # => 42
# another 3 seconds later...
a.call # => 42
# calculating
a.call # => 42
a.call # => 42
```

### Checking if a Method is Memoized

```ruby
class A
  include Memery

  memoize def call
    puts "calculating"
    42
  end

  def execute
    puts "non-memoized"
  end
end

a = A.new

a.memoized?(:call) # => true
a.memoized?(:execute) # => false
```

If you want to see memoized method source:

```ruby
class A
  include Memery

  memoize def call
    puts "calculating"
    42
  end
end

# This will print memoization logic, don't use it.
# The same for `show-source A#call` in `pry`.
puts A.instance_method(:call).source

# And this will work correctly.
puts A.memoized_methods[:call].source
```

But if a memoized method has been defined in an included module — it'd be a bit harder:

```ruby
module A
  include Memery

  memoize def foo
    'source'
  end
end

module B
  include Memery
  include A

  memoize def foo
    "Get this #{super}!"
  end
end

class C
  include B
end

puts C.instance_method(:foo).owner.memoized_methods[:foo].source
# memoize def foo
#   "Get this #{super}!"
# end

puts C.instance_method(:foo).super_method.owner.memoized_methods[:foo].source
# memoize def foo
#   'source'
# end
```

### Object Shape Optimization

In Ruby 3.2, a new optimization called "object shape" was introduced,
which can have negative interactions with dynamically added instance variables.
Alt Memery minimizes this impact by introducing only one new instance variable
after initialization (`@_memery_memoized_values`). If you need to ensure a specific object shape,
you can call `clear_memery_cache!` in your initializer to set the instance variable ahead of time.

## Development

After checking out the repo, run `bundle install` to install dependencies.

Then, run `toys rspec` to run the tests.

To install this gem onto your local machine, run `toys gem install`.

To release a new version, run `toys gem release %version%`.
See how it works [here](https://github.com/AlexWayfer/gem_toys#release).

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/AlexWayfer/alt_memery>.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
