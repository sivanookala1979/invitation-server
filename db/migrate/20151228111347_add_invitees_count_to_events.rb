class AddInviteesCountToEvents < ActiveRecord::Migration
  def change
    add_column :events, :invitees_count, :integer
    add_column :events, :accepted_count, :integer
    add_column :events, :rejected_count, :integer
  end
end
