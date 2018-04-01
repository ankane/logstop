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
- passwords in urls [master]

Works with all types of logging - Ruby, ActiveRecord, ActiveJob, and more

```
User Load (0.1ms)  SELECT "users".* FROM "users" WHERE "users"."email" = ?  [["email", "[FILTERED]"]]
```

## Installation

Add this line to your application’s Gemfile:

```ruby
gem 'logstop'
```

And add it to your logger:

```ruby
logger.formatter = Logstop::Formatter.new(logger.formatter)
```

## Options

To scrub IP addresses, use:

```ruby
Logstop::Formatter.new(formatter, ip: true)
```

## Note

This should be used in addition to `config.filtered_parameters`, not as a replacement.

To scrub existing log files, check out [scrubadub](https://github.com/datascopeanalytics/scrubadub).

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
