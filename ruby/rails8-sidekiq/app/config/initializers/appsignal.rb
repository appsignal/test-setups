class Appsignal::EventSubscriber
  def initialize
    @logger = Appsignal::Logger.new("rails_events")
  end

  def emit(event)
    name = event[:name]
    payload = event[:payload] || {}

    # Extract relevant data from payload and sanitize for logging
    log_attributes = {
      event_name: name,
      event_time: event[:time]&.iso8601
    }

    # Add payload data as attributes
    payload.each do |key, value|
      # Convert to string for complex objects to avoid serialization issues
      log_attributes[key] = value.is_a?(String) || value.is_a?(Numeric) ? value : value.to_s
    end

    # Log the event
    @logger.info("Rails event: #{name}", log_attributes)
  end
end

Rails.event.subscribe(Appsignal::EventSubscriber.new())
