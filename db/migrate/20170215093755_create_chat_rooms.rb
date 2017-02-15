class CreateChatRooms < ActiveRecord::Migration
  def change
    create_table :chat_rooms do |t|
      t.integer :user_id
      t.integer :other_id
      t.boolean :support, :default => false
      t.boolean :is_group, :default => false

      t.timestamps
    end
  end
end
