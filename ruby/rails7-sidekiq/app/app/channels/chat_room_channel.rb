class ChatRoomChannel < ApplicationCable::Channel
  def subscribed
    room_id = params[:chat_room_id]
    reject unless room_id.present?

    chat_room = ChatRoom.find(room_id)
    stream_for chat_room
  end

  def speak(data)
    ActionCable.server.broadcast(
      "chat_#{params[:chat_room_id]}", :text => data["message"]
    )
  end

  def echo(data)
    data.delete("action")
    transmit data
  end
end
