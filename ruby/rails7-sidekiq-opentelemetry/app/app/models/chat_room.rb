class ChatRoom < ApplicationRecord
  has_many :chat_messages
  validates_uniqueness_of :name
  after_create_commit do
    broadcast_append_to "rooms"
  end
end
