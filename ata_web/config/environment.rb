# Load the Rails application.
require_relative "application"

# Initialize the Rails application.
Rails.application.initialize!

unless Rails.logger.respond_to?(:broadcast_to)
  Rails.logger = ActiveSupport::BroadcastLogger.new(Rails.logger)
end
