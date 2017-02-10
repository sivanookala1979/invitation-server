class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :image_path
      t.string :image_path_file_name
      t.string :image_path_content_type
      t.integer :image_path_file_size
      t.datetime :image_path_updated_at

      t.timestamps
    end
  end
end
