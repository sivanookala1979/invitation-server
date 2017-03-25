class RemoveHideFromEvents < ActiveRecord::Migration
  def up
    remove_column :events, :hide
    add_column :events, :hide, :boolean, :default=>false
  end

  def down
    add_column :events, :hide, :boolean
  end
end
