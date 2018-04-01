require "logger"

module Logstop
  class Formatter < ::Logger::Formatter
    def initialize(formatter = nil, ip: false)
      @formatter = formatter || ::Logger::Formatter.new
      @ip = ip
    end

    def call(severity, timestamp, progname, msg)
      Logstop.scrub(@formatter.call(severity, timestamp, progname, msg), ip: @ip)
    end
  end
end
