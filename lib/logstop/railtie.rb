module Logstop
  class Railtie < Rails::Railtie
    console do
      # make broadcaster inherit formatter
      # yes, these are the same, but it works
      Rails.logger.formatter = Rails.logger.formatter
    end
  end
end
