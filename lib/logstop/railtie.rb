module Logstop
  class Railtie < Rails::Railtie
    console do
      # make broadcaster inherit formatter
      if Rails.logger && Rails.logger.formatter.is_a?(Logstop::Formatter)
        # yes, these are the same, but it works
        Rails.logger.formatter = Rails.logger.formatter
      end
    end
  end
end
