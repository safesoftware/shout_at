# ShoutAt

ShoutAt is a centralized notification framework for Ruby to notify different teams with different services based on 
urgency.  
It currently supports the following services:
* Log
* Email
* PagerDuty
* Slack
* Airbrake

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'shout_at'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install shout_at

## Usage

### Example config
```YAML
production: &production
  devops:
    loud:
      channel: "pagerduty"
      service_key: "<%= ENV['PAGERDUTY_SERVICE_KEY'] %>"
    quiet:
      channel: "airbrake"
    silent:
      channel: "log"
  support:
    loud:
      channel: "pagerduty"
      service_key: "<%= ENV['PAGERDUTY_SUPPORT_SERVICE_KEY'] %>"
    quiet:
      channel: "email"
      to: "support@example.com"
      mailer_name: "IncidentMailer"
  sales:
    quiet:
      channel: "email"
      to: "sales@example.com"
      mailer_name: "SalesMailer"
  safe:
    excited:
      channel: "slack"
      web_hook: <%= ENV['SLACK_WEBHOOK'] %>
```

### Rails example usage
```ruby
ShoutAt.init(YAML.load(ERB.new(File.read(Rails.root + "config/shout_at.yml")).result)[Rails.env], Rails.logger)  
ShoutAt::Sales.excited('We just sold our lives!')
ShoutAt::Devops.loud('Wake up!')
ShoutAt::Support.quiet('You should look into that!')
```

### Error Handling

Shouters will never throw an exception, by default all errors generated by Shouters end up in the defined logger.
If custom error handling is preferred, a custom _proc_ can be set before the initialization. The proc needs to handle
the exception. 

Example with Airbrake:  
`ShoutAt.rescue_handler = Proc.new { |exception| Airbrake.notify(exception) }`

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/safesoftware/shout_at.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

