# AppReputation

[![Build Status](https://travis-ci.org/thyrlian/AppReputation.svg?branch=master)](https://travis-ci.org/thyrlian/AppReputation)
[![Coverage Status](https://coveralls.io/repos/github/thyrlian/AppReputation/badge.svg?branch=master)](https://coveralls.io/github/thyrlian/AppReputation?branch=master)
[![Code Climate](https://codeclimate.com/github/thyrlian/AppReputation/badges/gpa.svg)](https://codeclimate.com/github/thyrlian/AppReputation)

Ruby gem for retrieving application's **ratings** and **reviews** from the most popular mobile platforms ( [Android](https://play.google.com/store/apps) & [iOS](https://itunes.apple.com/us/genre/ios/id36?mt=8) ).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'app_reputation'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install app_reputation

## Usage

```ruby
require 'app_reputation'

include AppReputation

android_app_id = 'com.example.app'
ios_app_id = 123456789

# Android Ratings

# iOS Ratings
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## License

Copyright (c) 2016 Jing Li. The gem is released under the [MIT License](http://opensource.org/licenses/MIT). See the [LICENSE](https://github.com/thyrlian/AppReputation/blob/master/LICENSE) file for details.
