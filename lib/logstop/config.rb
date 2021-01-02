module Logstop
	class << self
		def configure
			yield config
		end

		def config
			@config ||= Config.new
		end
	end

	class Config
		attr_accessor :scrub_attributes

		def initialize
			@scrub_attributes = scrub_attributes
		end
	end
end
