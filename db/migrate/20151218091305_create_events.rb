class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :event_name
      t.datetime :end_date
      t.string :description
      t.float :latitude
      t.float :longitude
      t.string :address
      t.boolean :private
      t.boolean :remainder
      t.string :status
      t.integer :owner_id
      t.datetime :start_date

      t.timestamps
    end
  end
end
