class CreateGroups < ActiveRecord::Migration
  def change
    create_table :groups do |t|
      t.string :group_name
      t.integer :owner_id
      t.string :contact_numbers

      t.timestamps
    end
  end
end
