require "rails/generators"

module Logstop
	module Generators
		class ConfigGenerator < Rails::Generators::Base
			source_root File.expand_path("templates", __dir__)

			# Generates default Logstop configuration file into your application config/initializers directory.
			def copy_config_file
				copy_file "logstop_config.rb", "config/initializers/logstop.rb"
			end
		end
	end
end
