require "logger"

module Logstop
  class Formatter < ::Logger::Formatter
    FILTERED_STR = "[FILTERED]".freeze
    FILTERED_URL_STR = "\\1[FILTERED]@".freeze

    CREDIT_CARD_REGEX = /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/
    EMAIL_REGEX = /\b[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\b/i
    IP_REGEX = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
    PHONE_REGEX = /\b(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/i
    SSN_REGEX = /\b\d{3}[\s-]?\d{2}[\s-]?\d{4}\b/i
    URL_PASSWORD_REGEX = /(\/\/\S+:)\S+@/

    def initialize(formatter = nil, ip: false)
      @formatter = formatter || ::Logger::Formatter.new
      @ip = ip
    end

    def call(severity, timestamp, progname, msg)
      output = @formatter.call(severity, timestamp, progname, msg)
      output = output.gsub(IP_REGEX, FILTERED_STR) if @ip

      # order filters are applied is important
      output
        .gsub(CREDIT_CARD_REGEX, FILTERED_STR)
        .gsub(PHONE_REGEX, FILTERED_STR)
        .gsub(SSN_REGEX, FILTERED_STR)
        .gsub(EMAIL_REGEX, FILTERED_STR)
        .gsub(URL_PASSWORD_REGEX, FILTERED_URL_STR)
    end
  end
end
