require_relative "lib/logstop/version"

Gem::Specification.new do |spec|
  spec.name          = "logstop"
  spec.version       = Logstop::VERSION
  spec.summary       = "Keep personal data out of your logs"
  spec.homepage      = "https://github.com/ankane/logstop"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@ankane.org"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.7"
end
