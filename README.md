# Logstop

:fire: Keep personally identifiable information (PII) out of your logs

```ruby
logger.info "Hi test@test.com!"
# => Hi [FILTERED]!
```

By default, scrubs:

- email addresses
- phone numbers
- credit card numbers
- Social Security numbers (SSNs)
- passwords in urls

Works with all types of logging - Ruby, ActiveRecord, ActiveJob, and more

```
User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."email" = ?  [["email", "[FILTERED]"]]
```

[![Build Status](https://travis-ci.org/ankane/logstop.svg?branch=master)](https://travis-ci.org/ankane/logstop)

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'logstop'
```

And add it to your logger:

```ruby
logger.formatter = Logstop::Formatter.new(logger.formatter)
```

### Rails

Create `config/initializers/logstop.rb` with:

```ruby
Rails.logger.formatter = Logstop::Formatter.new(Rails.logger.formatter)
```

**Note:** In the Rails console with the default logger, logs show up unfiltered in STDOUT, but filtered in the log file.

## Options

To scrub IP addresses, use:

```ruby
Logstop::Formatter.new(formatter, ip: true)
```

To scrub outside of logging, use:

```ruby
Logstop.scrub(msg)
```

## Note

This should be used in addition to `config.filtered_parameters`, not as a replacement.

To scrub existing log files, check out [scrubadub](https://github.com/datascopeanalytics/scrubadub).

To anonymize IP addresses, check out [IP Anonymizer](https://github.com/ankane/ip_anonymizer).

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
