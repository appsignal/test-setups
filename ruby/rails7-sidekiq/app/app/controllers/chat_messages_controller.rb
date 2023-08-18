class ChatMessagesController < ApplicationController
  def create
    chat_message_params = params[:chat_message].permit(:body, :chat_room_id)
    @chat_room = ChatRoom.find(chat_message_params.delete(:chat_room_id))
    @chat_message = @chat_room.chat_messages.new(chat_message_params)
    if @chat_message.save
      ChatRoomChannel.broadcast_to @chat_message.chat_room, @chat_message
    end
  end
end
