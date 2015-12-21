class CreateUserAccessTokens < ActiveRecord::Migration
  def change
    create_table :user_access_tokens do |t|
      t.integer :user_id
      t.string :access_token

      t.timestamps
    end
  end
end
