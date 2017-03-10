class CreateServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name
      t.integer :image_id
      t.boolean :is_active

      t.timestamps
    end
  end
end
