class Appsignal::EventSubscriber
  def initialize
    @logger = Appsignal::Logger.new("rails_events")
  end

  def emit(event)
    pp event
    @logger.info(event[:name], event)
  end
end

Rails.event.subscribe(Appsignal::EventSubscriber.new())
