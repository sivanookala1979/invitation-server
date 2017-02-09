class CreateGroupMembers < ActiveRecord::Migration
  def change
    create_table :group_members do |t|
      t.integer :group_id
      t.integer :user_id
      t.boolean :is_group_admin, :default => false
      t.string :user_name
      t.string :user_mobile_number

      t.timestamps
    end
  end
end
