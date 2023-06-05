require_relative "logstop/formatter"
require_relative "logstop/railtie" if defined?(Rails)
require_relative "logstop/version"

module Logstop
  FILTERED_STR = "[FILTERED]".freeze
  FILTERED_URL_STR = "\\1[FILTERED]\\2".freeze

  CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/
  CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/
  EMAIL_REGEX = /\b[\w]([\w+.-]|%2B)+(?:@|%40)[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i
  IP_REGEX = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
  PHONE_REGEX = /\b(?:\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/
  E164_PHONE_REGEX = /(?:\+|%2B)[1-9]\d{6,14}\b/
  SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/
  URL_PASSWORD_REGEX = /((?:\/\/|%2F%2F)\S+(?::|%3A))\S+(@|%40)/
  MAC_REGEX = /\b[0-9a-f]{2}(?:(?::|%3A)[0-9a-f]{2}){5}\b/i

  def self.scrub(msg, url_password: true, email: true, credit_card: true, phone: true, ssn: true, ip: false, mac: false, scrubber: nil)
    msg = msg.to_s.dup

    # order filters are applied is important
    msg.gsub!(URL_PASSWORD_REGEX, FILTERED_URL_STR) if url_password
    msg.gsub!(EMAIL_REGEX, FILTERED_STR) if email
    if credit_card
      msg.gsub!(CREDIT_CARD_REGEX, FILTERED_STR)
      msg.gsub!(CREDIT_CARD_REGEX_DELIMITERS, FILTERED_STR)
    end
    if phone
      msg.gsub!(E164_PHONE_REGEX, FILTERED_STR)
      msg.gsub!(PHONE_REGEX, FILTERED_STR)
    end
    msg.gsub!(SSN_REGEX, FILTERED_STR) if ssn
    msg.gsub!(IP_REGEX, FILTERED_STR) if ip
    msg.gsub!(MAC_REGEX, FILTERED_STR) if mac

    msg = scrubber.call(msg) if scrubber

    msg
  end

  def self.guard(logger, **options)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
  end
end
