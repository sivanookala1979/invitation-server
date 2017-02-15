class AddPersistenceTokenToUsers < ActiveRecord::Migration
  def change
    add_column :users, :persistence_token, :string
    add_column :users, :gcm_code, :string
  end
end
