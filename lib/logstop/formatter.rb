require "logger"

module Logstop
  class Formatter < ::Logger::Formatter
    def initialize(formatter = nil, url_password: true, email: true, credit_card: true, phone: true, ssn: true, ip: false, mac: false, scrubber: nil)
      @formatter = formatter || ::Logger::Formatter.new
      @url_password = url_password
      @email = email
      @credit_card = credit_card
      @phone = phone
      @ssn = ssn
      @ip = ip
      @mac = mac
      @scrubber = scrubber
    end

    def call(severity, timestamp, progname, msg)
      Logstop.scrub(
        @formatter.call(severity, timestamp, progname, msg),
        url_password: @url_password,
        email: @email,
        credit_card: @credit_card,
        phone: @phone,
        ssn: @ssn,
        ip: @ip,
        mac: @mac,
        scrubber: @scrubber
      )
    end

    # for tagged logging
    def method_missing(method_name, ...)
      @formatter.send(method_name, ...)
    end

    def respond_to_missing?(method, include_private = false)
      @formatter.respond_to?(method) || super
    end

    # for tagged logging
    def respond_to?(method_name, include_private = false)
      @formatter.send(:respond_to?, method_name, include_private) || super
    end
  end
end
