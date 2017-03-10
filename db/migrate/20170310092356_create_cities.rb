class CreateCities < ActiveRecord::Migration
  def change
    create_table :cities do |t|
      t.string :name
      t.integer :image_id
      t.boolean :active
      t.decimal :latitude
      t.decimal :longitude
      t.text :remarks
      t.string :pincode

      t.timestamps
    end
  end
end
