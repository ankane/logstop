Logstop.configure do |config|
  config.scrub_attributes = %w[]
end

Logstop.guard(Rails.logger)
