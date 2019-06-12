require_relative "lib/logstop/version"

Gem::Specification.new do |spec|
  spec.name          = "logstop"
  spec.version       = Logstop::VERSION
  spec.summary       = "Keep personally identifiable information (PII) out of your logs"
  spec.homepage      = "https://github.com/ankane/logstop"
  spec.license       = "MIT"

  spec.author        = "Andrew Kane"
  spec.email         = "andrew@chartkick.com"

  spec.files         = Dir["*.{md,txt}", "{lib}/**/*"]
  spec.require_path  = "lib"

  spec.required_ruby_version = ">= 2.2"

  spec.add_development_dependency "activesupport"
  spec.add_development_dependency "benchmark-ips"
  spec.add_development_dependency "bundler"
  spec.add_development_dependency "memory_profiler"
  spec.add_development_dependency "minitest"
  spec.add_development_dependency "rake"
end
