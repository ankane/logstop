require "logstop/formatter"
require "logstop/railtie" if defined?(Rails)
require "logstop/version"
require "resolv"

module Logstop
  FILTERED_STR = "[FILTERED]".freeze
  FILTERED_URL_STR = "\\1[FILTERED]@".freeze

  CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/
  CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/
  EMAIL_REGEX = /\b[\w][\w+.-]+(@|%40)[a-z\d-]+(\.[a-z\d-]+)*\.[a-z]+\b/i
  IP_REGEX = Regexp.new(Resolv::AddressRegex.source.gsub('\A', '\b').gsub('\z', '\b'))
  PHONE_REGEX = /\b(\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/
  SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/
  URL_PASSWORD_REGEX = /((\/\/|%2F%2F)\S+(:|%3A))\S+(@|%40)/

  def self.scrub(msg, ip: false, scrubber: nil)
    msg = msg.to_s.dup

    # order filters are applied is important
    msg.gsub!(URL_PASSWORD_REGEX, FILTERED_URL_STR)
    msg.gsub!(EMAIL_REGEX, FILTERED_STR)
    msg.gsub!(CREDIT_CARD_REGEX, FILTERED_STR)
    msg.gsub!(CREDIT_CARD_REGEX_DELIMITERS, FILTERED_STR)
    msg.gsub!(PHONE_REGEX, FILTERED_STR)
    msg.gsub!(SSN_REGEX, FILTERED_STR)

    msg.gsub!(IP_REGEX, FILTERED_STR) if ip

    msg = scrubber.call(msg) if scrubber

    msg
  end

  def self.guard(logger, **options)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
  end
end
