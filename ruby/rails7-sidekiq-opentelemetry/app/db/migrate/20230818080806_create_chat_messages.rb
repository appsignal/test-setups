class CreateChatMessages < ActiveRecord::Migration[7.0]
  def change
    create_table :chat_messages do |t|
      t.string :body
      t.references :chat_room, null: false, foreign_key: true

      t.timestamps
    end
  end
end
