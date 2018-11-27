require "ipaddr"
require "openssl"

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

  def self.hash_ip(ip, key:, iterations: 1)
    addr = IPAddr.new(ip.to_s)
    key_len = addr.ipv4? ? 4 : 16
    family = addr.ipv4? ? Socket::AF_INET : Socket::AF_INET6

    keyed_hash = OpenSSL::PKCS5.pbkdf2_hmac(addr.to_s, key, iterations, key_len, "sha256")
    IPAddr.new(keyed_hash.bytes.inject {|a, b| (a << 8) + b}, family).to_s
  end

  def self.scrub(msg, ip: false, key: nil, extra_rules: [])
    msg = msg.to_s

    if ip && key && msg.match(IP_REGEX)
      msg = msg.gsub(IP_REGEX, self.hash_ip(msg.match(IP_REGEX)[0], key: key))
    elsif ip
      msg = msg.gsub(IP_REGEX, FILTERED_STR)
    end

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
