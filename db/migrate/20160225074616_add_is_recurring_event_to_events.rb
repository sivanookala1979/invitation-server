class AddIsRecurringEventToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_recurring_event, :boolean
    add_column :events, :recurring_type, :string
    add_column :events, :event_theme, :string
    add_column :events, :hide, :boolean
  end
end
