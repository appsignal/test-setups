class Appsignal::EventSubscriber
  def emit(event)
    pp event
  end
end

Rails.event.subscribe(Appsignal::EventSubscriber.new())
