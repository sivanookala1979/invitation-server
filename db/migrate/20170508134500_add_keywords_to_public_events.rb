class AddKeywordsToPublicEvents < ActiveRecord::Migration
  def change
    add_column :public_events, :keyword1, :string
    add_column :public_events, :keyword2, :string
    add_column :public_events, :keyword3, :string
    add_column :public_events, :keyword4, :string
    add_column :public_events, :keyword5, :string
    add_column :public_events, :booking_available_from, :datetime
    add_column :public_events, :booking_closed_at, :datetime
    add_column :public_events, :avilable_tickets, :integer, :default => 0
    add_column :public_events, :booked_tickets, :integer, :default => 0
    add_column :public_events, :total_tickets_for_booking, :integer, :default => 0
  end
end
