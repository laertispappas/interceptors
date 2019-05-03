# Interceptors

[Pedestal](http://pedestal.io/reference/interceptors) like interceptors pipe and filter service objects in Ruby. Common use cases like http service objects or multiple steps business workflow. 

## Installation

Add     this line to your application's Gemfile:

```ruby
gem 'interceptors'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install interceptors

## Overview

TBD

## Usage examples

Create your interceptors by extending `Interceptors::Base` class and define one of `on_enter`, `on_leave` or `on_error` method based on your use case. Register each one of them to an `Interceptors::Executor` instance and send `#call` message on it. Implement your logic in each interceptor service per use case.


```ruby

``` 

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/laertispappas/interceptors. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Interceptors project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/interceptors/blob/master/CODE_OF_CONDUCT.md).

## Acknowledgments
