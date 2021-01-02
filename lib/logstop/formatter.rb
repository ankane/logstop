require "logger"

module Logstop
  class Formatter < ::Logger::Formatter
    def initialize(formatter = nil, ip: false, scrubber: nil, active_record: false)
      @formatter = formatter || ::Logger::Formatter.new
      @ip = ip
			@scrubber = scrubber
			@active_record = active_record
    end

    def call(severity, timestamp, progname, msg)
      Logstop.scrub(@formatter.call(severity, timestamp, progname, msg), ip: @ip, scrubber: @scrubber, active_record: @active_record)
    end

    # for tagged logging
    def method_missing(method_name, *arguments, &block)
      @formatter.send(method_name, *arguments, &block)
    end

    # for tagged logging
    def respond_to?(method_name, include_private = false)
      @formatter.send(:respond_to?, method_name, include_private) || super
    end
  end
end
