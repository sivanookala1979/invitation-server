class CreateFavourites < ActiveRecord::Migration
  def change
    create_table :favourites do |t|
      t.integer :user_id
      t.integer :city_id
      t.integer :event_id

      t.timestamps
    end
  end
end
