# Logstop

:fire: Keep personally identifiable information (PII) out of your logs

```ruby
logger.info "Hi test@example.org!"
# => Hi [FILTERED]!
```

By default, scrubs:

- email addresses
- phone numbers
- credit card numbers
- Social Security numbers (SSNs)
- passwords in URLs

Works with all types of logging - Ruby, Active Record, Active Job, and more

```
User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."email" = ?  [["email", "[FILTERED]"]]
```

Works even when sensitive data is URL-encoded with plus encoding

[![Build Status](https://github.com/ankane/logstop/workflows/build/badge.svg?branch=master)](https://github.com/ankane/logstop/actions)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'logstop'
```

And add it to your logger:

```ruby
Logstop.guard(logger)
```

### Rails

Create `config/initializers/logstop.rb` with:

```ruby
Logstop.guard(Rails.logger)
```

## Options

To scrub IP addresses (IPv4), use:

```ruby
Logstop.guard(logger, ip: true)
```

Add custom rules with:

```ruby
scrubber = lambda do |msg|
  msg.gsub(/custom_regexp/, "[FILTERED]".freeze)
end

Logstop.guard(logger, scrubber: scrubber)
```

Disable default rules with: [unreleased]

```ruby
Logstop.guard(logger,
  email: false,
  phone: false,
  credit_card: false,
  ssn: false,
  url_password: false
)
```

To scrub outside of logging, use:

```ruby
Logstop.scrub(msg)
```

It supports the same options as `guard`.

## Notes

This should be used in addition to `config.filter_parameters`, not as a replacement.

Learn more about [securing sensitive data in Rails](https://ankane.org/sensitive-data-rails).

Also:

- To scrub existing log files, check out [scrubadub](https://github.com/datascopeanalytics/scrubadub)
- To anonymize IP addresses, check out [IP Anonymizer](https://github.com/ankane/ip_anonymizer)
- To scan for unencrypted personal data in your database, check out [pdscan](https://github.com/ankane/pdscan)

## Resources

- [List of PII, as defined by NIST](https://en.wikipedia.org/wiki/Personally_identifiable_information#NIST_definition)

## History

View the [changelog](CHANGELOG.md)

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/ankane/logstop/issues)
- Fix bugs and [submit pull requests](https://github.com/ankane/logstop/pulls)
- Write, clarify, or fix documentation
- Suggest or add new features

To get started with development:

```sh
git clone https://github.com/ankane/logstop.git
cd logstop
bundle install
bundle exec rake test
```
