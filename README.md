# Fiber::Collector

[![Gem Version](https://badge.fury.io/rb/fiber-collector.svg)](https://badge.fury.io/rb/fiber-collector)

An easy way to schedule and aggregate the results from multiple concurrent tasks inspired by JavaScript's `Promise.all()`, `Promise.any()` and `Promise.race()` methods.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add fiber-collector

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install fiber-collector

## Usage

Here are some examples where `sleep` is the non-blocking operation, but it could just as well be replaced with calls to `Net::HTTP.get()` or other I/O.

```ruby
# needs a fiber scheduler
require 'async'

# Sets the fiber scheduler and executes inside a non-blocking fiber
Async do
  # Collect all results
  Fiber::Collector.schedule { sleep 0.001; 'a' }
      .and { sleep 0.002; 'b' }
      .and { sleep 0.003; 'c' }
      .all(timeout: 0.02)
end.wait
# => ['a', 'b', 'c']

Async do
  Fiber::Collector.schedule { sleep 0.001; 'a' }
      .and { sleep 0.002; raise 'boom' }
      .and { sleep 0.003; 'c' }
      .all
end.wait
# RuntimeError raised

Async do
  Fiber::Collector.schedule { sleep 0.010; 'a' }
      .and { sleep 0.001; raise 'e' }
      .and { sleep 0.005; 'b' } 
      .and { sleep 0.007; 'c' }
      .any(timeout: 0.02)    
end.wait
# => 'b'

Async do
  Fiber::Collector.schedule { sleep 0.010; 'a' }
      .and { sleep 0.001; raise XError }
      .and { sleep 0.005; 'b' } 
      .and { sleep 0.007; raise YError }
      .race(timeout: 0.02)    
end.wait
# XError raised

Async do
  Fiber::Collector.schedule { sleep 0.010; raise XError }
      .and { sleep 0.001; 'a' }
      .and { sleep 0.005; 'b' } 
      .and { sleep 0.007; raise YError }
      .race(timeout: 0.02)    
end.wait
# => "a"
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/beatmadsen/fiber-collector. 

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).