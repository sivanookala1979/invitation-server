class AddIsProfileGivenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_profile_given, :boolean, default: false
    add_column :users, :status, :string
    add_column :users, :image_id, :integer
  end
end
