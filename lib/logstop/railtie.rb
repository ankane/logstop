module Logstop
  class Railtie < Rails::Railtie
    console do
      # make broadcaster inherit formatter
      if Rails.logger && Rails.logger.formatter.is_a?(Logstop::Formatter)
        # yes, these are the same, but it works
        # rubocop:disable Lint/SelfAssignment
        Rails.logger.formatter = Rails.logger.formatter
        # rubocop:enable Lint/SelfAssignment
      end
    end
  end
end
