class AddIsAppLoginToUsers < ActiveRecord::Migration
  def change
    add_column :users, :is_app_login, :boolean, :default => false
  end
end
