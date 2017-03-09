class AddEventIdToChatMessages < ActiveRecord::Migration
  def change
    add_column :chat_messages, :event_id, :integer
  end
end
