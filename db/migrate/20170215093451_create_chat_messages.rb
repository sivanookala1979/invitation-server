class CreateChatMessages < ActiveRecord::Migration
  def change
    create_table :chat_messages do |t|
      t.integer :chat_room_id
      t.integer :from_id
      t.string :message

      t.timestamps
    end
  end
end
