class CreatePublicEvents < ActiveRecord::Migration
  def change
    create_table :public_events do |t|
      t.string :event_name
      t.string :event_theme
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :entry_fee,:default=>0.0
      t.integer :city_id
      t.integer :service_id
      t.text :description
      t.integer :image_id
      t.string :address
      t.boolean :is_active

      t.timestamps
    end
  end
end
