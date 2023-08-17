class ChatChannel < ApplicationCable::Channel
  def subscribed
    reject unless params[:room_id].present?
  end

  def speak(data)
    ActionCable.server.broadcast(
      "chat_#{params[:room_id]}", text: data['message']
    )
  end

  def echo(data)
    data.delete("action")
    transmit data
  end
end
