class AddIsWeekendToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :is_weekend, :boolean
  end
end
