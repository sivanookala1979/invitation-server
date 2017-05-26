class CreateUserSettings < ActiveRecord::Migration
  def change
    create_table :user_settings do |t|
      t.integer :user_id
      t.boolean :share_location_with_host, :default=>false
      t.boolean :share_locattion_with_guest, :default=>false
      t.boolean :invitations, :default=>false
      t.boolean :reminders, :default=>false
      t.boolean :comments, :default=>false

      t.timestamps
    end
  end
end
