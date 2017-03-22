class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.integer :user_id
      t.integer :event_id
      t.string :notification_type
      t.boolean :notified

      t.timestamps
    end
  end
end
