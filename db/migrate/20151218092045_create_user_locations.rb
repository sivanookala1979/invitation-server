class CreateUserLocations < ActiveRecord::Migration
  def change
    create_table :user_locations do |t|
      t.integer :user_id
      t.float :latitude
      t.float :longitude
      t.datetime :time

      t.timestamps
    end
  end
end
