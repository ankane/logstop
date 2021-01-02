require "logstop/formatter"
require "logstop/railtie" if defined?(Rails)
require "logstop/version"
require "logstop/config"

module Logstop
  FILTERED_STR = "[FILTERED]".freeze
  FILTERED_URL_STR = "\\1[FILTERED]\\2".freeze

  CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/
  CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/
  EMAIL_REGEX = /\b[\w][\w+.-]+(?:@|%40)[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i
  IP_REGEX = /\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b/
  PHONE_REGEX = /\b(?:\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/
  SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/
  URL_PASSWORD_REGEX = /((?:\/\/|%2F%2F)\S+(?::|%3A))\S+(@|%40)/

  def self.scrub(msg, ip: false, scrubber: nil, active_record: false)
    msg = msg.to_s.dup

    # order filters are applied is important
    msg.gsub!(URL_PASSWORD_REGEX, FILTERED_URL_STR)
    msg.gsub!(EMAIL_REGEX, FILTERED_STR)
    msg.gsub!(CREDIT_CARD_REGEX, FILTERED_STR)
    msg.gsub!(CREDIT_CARD_REGEX_DELIMITERS, FILTERED_STR)
    msg.gsub!(PHONE_REGEX, FILTERED_STR)
    msg.gsub!(SSN_REGEX, FILTERED_STR)

    msg.gsub!(IP_REGEX, FILTERED_STR) if ip
    scrub_active_record_attributes(msg) if active_record

    msg = scrubber.call(msg) if scrubber

    msg
  end

  def self.guard(logger, **options)
    logger.formatter = Logstop::Formatter.new(logger.formatter, **options)
  end
	
  def self.scrub_active_record_attributes(msg)
		Logstop.config.scrub_attributes.each do |attribute_name|
			next if attribute_scrubbed?(msg, attribute_name)
	
			msg.gsub!(attribute_regex(attribute_name), filtered_attribute_str(attribute_name))
		end
		msg
	end
	
	def self.attribute_scrubbed?(msg, attribute_name)
		msg.include? filtered_attribute_str(attribute_name)
	end
	
	def self.attribute_regex(attribute_name)
		/\["#{attribute_name}", [^\[,]*/
	end
	
	def self.filtered_attribute_str(attribute_name)
		"[\"#{attribute_name}\", \"#{FILTERED_STR}\"]"
	end
end
