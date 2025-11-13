class Appsignal::EventSubscriber
  def emit(event)
    name = "#{event[:name].split(".").reverse.join(".")}_event"

    case event[:name]
    when "action_controller.request_started", "action_view.render_start", "action_view.render_start"
      start(name, event)
    when "action_view.render_template", "action_view.render_layout", "action_controller.request_completed"
      stop(name, event)
    end
  end

  def start(name, event)
    Appsignal::Transaction.current.start_event()
  end

  def stop(name, event)
    title, body, body_format = Appsignal::EventFormatter.format(name, event[:payload])
    Appsignal::Transaction.current.finish_event(name, title, body, body_format)
  end
end

Rails.event.subscribe(Appsignal::EventSubscriber.new())
