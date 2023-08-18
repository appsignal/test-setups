class ChatRoomsController < ApplicationController
  def index
    @chat_rooms = ChatRoom.all
    unless @chat_rooms.any?
      ChatRoom.create!(:name => "#general room")
      ChatRoom.create!(:name => "#random room")
      @chat_rooms = ChatRoom.all
    end
  end

  def show
    @chat_room = ChatRoom.find(params[:id])
    @chat_messages = @chat_room.chat_messages
    @chat_message = ChatMessage.new
  end
end
