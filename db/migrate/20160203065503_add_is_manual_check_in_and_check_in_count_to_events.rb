class AddIsManualCheckInAndCheckInCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_manual_check_in, :boolean, :default=>false
    add_column :events, :check_in_count, :integer
  end
end
