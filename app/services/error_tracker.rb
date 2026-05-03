module ErrorTracker
  def self.error(message)
    if defined?(Rollbar)
      Rollbar.error(message)
    else
      Rails.logger.error(message)
    end
  end
end
