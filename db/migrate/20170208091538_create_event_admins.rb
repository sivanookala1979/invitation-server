class CreateEventAdmins < ActiveRecord::Migration
  def change
    create_table :event_admins do |t|
      t.integer :event_id
      t.integer :user_id

      t.timestamps
    end
  end
end
