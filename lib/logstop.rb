require "logstop/formatter"
require "logstop/railtie" if defined?(Rails)
require "logstop/version"

module Logstop
  FILTERED_STR = "[FILTERED]".freeze
  FILTERED_URL_STR = "\\1[FILTERED]\\2".freeze

  CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/
  CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/
  EMAIL_REGEX = /\b[\w]([\w+.-]|%2B)+(?:@|%40)[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i
  IP_REGEX = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
  PHONE_REGEX = /\b(?:\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/
  SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/
  URL_PASSWORD_REGEX = /((?:\/\/|%2F%2F)\S+(?::|%3A))\S+(@|%40)/

  DEFAULT_OPTIONS = {
    password: true,
    email: true,
    credit_card: true,
    phone: true,
    ssn: true,
    ip: false,
    scrubber: nil,
  }.freeze

  def self.scrub(msg, **options)
    msg = msg.to_s.dup
    if unknown_option_key = options.keys.find { |option_key| !DEFAULT_OPTIONS.include?(option_key) }
      raise ArgumentError, "unknown option #{unknown_option_key}"
    end
    options = DEFAULT_OPTIONS.merge(options)

    # order filters are applied is important
    msg.gsub!(URL_PASSWORD_REGEX, FILTERED_URL_STR) if options[:password]
    msg.gsub!(EMAIL_REGEX, FILTERED_STR) if options[:email]
    msg.gsub!(CREDIT_CARD_REGEX, FILTERED_STR) if options[:credit_card]
    msg.gsub!(CREDIT_CARD_REGEX_DELIMITERS, FILTERED_STR) if options[:credit_card]
    msg.gsub!(PHONE_REGEX, FILTERED_STR) if options[:phone]
    msg.gsub!(SSN_REGEX, FILTERED_STR) if options[:ssn]

    msg.gsub!(IP_REGEX, FILTERED_STR) if options[:ip]

    scrubber = options[:scrubber]
    msg = scrubber.call(msg) if scrubber

    msg
  end

  def self.guard(logger, **options)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
  end
end
