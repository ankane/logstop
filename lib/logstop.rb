require "logstop/formatter"
require "logstop/railtie" if defined?(Rails)
require "logstop/version"

module Logstop
  FILTERED_STR = "[FILTERED]".freeze
  FILTERED_URL_STR = "\\1[FILTERED]@".freeze

  CREDIT_CARD_REGEX = /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/
  EMAIL_REGEX = /\b[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\b/i
  IP_REGEX = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
  PHONE_REGEX = /\b(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]\d{3}[\s.-]\d{4}\b/
  SSN_REGEX = /\b\d{3}[\s-]\d{2}[\s-]\d{4}\b/
  URL_PASSWORD_REGEX = /(\/\/\S+:)\S+@/

  def self.scrub(msg, ip: false, extra_rules: [])
    msg = msg.to_s

    msg = msg.gsub(IP_REGEX, FILTERED_STR) if ip

    # order filters are applied is important
    msg = msg
      .gsub(CREDIT_CARD_REGEX, FILTERED_STR)
      .gsub(PHONE_REGEX, FILTERED_STR)
      .gsub(SSN_REGEX, FILTERED_STR)
      .gsub(URL_PASSWORD_REGEX, FILTERED_URL_STR)
      .gsub(EMAIL_REGEX, FILTERED_STR)

    extra_rules.inject(msg) { |m, rule| m.gsub(rule, FILTERED_STR) }
  end

  def self.guard(logger, **options)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
  end
end
